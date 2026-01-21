using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using app_me_api.Data;
using app_me_api.DTOs;
using app_me_api.Models;
using Microsoft.AspNetCore.SignalR;
using app_me_api.Hubs;

namespace app_me_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class GroupsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<GroupsController> _logger;
        private readonly IHubContext<ChatHub> _hubContext;

        public GroupsController(
            ApplicationDbContext context,
            ILogger<GroupsController> logger,
            IHubContext<ChatHub> hubContext)
        {
            _context = context;
            _logger = logger;
            _hubContext = hubContext;
        }

        private int? GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdClaim, out var userId) ? userId : null;
        }

        /// <summary>
        /// Get all groups user is a member of
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<List<GroupResponse>>> GetMyGroups()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var groups = await _context.GroupMembers
                    .Where(gm => gm.UserId == userId)
                    .Include(gm => gm.Group)
                        .ThenInclude(g => g.Owner)
                    .Include(gm => gm.Group)
                        .ThenInclude(g => g.Members)
                        .ThenInclude(m => m.User)
                    .Include(gm => gm.Group)
                        .ThenInclude(g => g.Messages)
                        .ThenInclude(m => m.Sender)
                    .Select(gm => gm.Group)
                    .ToListAsync();

                var groupResponses = groups.Select(g =>
                {
                    var lastMessage = g.Messages
                        .Where(m => !m.IsDeleted)
                        .OrderByDescending(m => m.CreatedAt)
                        .FirstOrDefault();

                    return new GroupResponse
                    {
                        Id = g.Id,
                        Name = g.Name,
                        Description = g.Description,
                        GroupPictureUrl = g.GroupPictureUrl,
                        OwnerId = g.OwnerId,
                        OwnerUsername = g.Owner.Username,
                        Members = g.Members.Select(m => new GroupMemberResponse
                        {
                            UserId = m.UserId,
                            Username = m.User.Username,
                            FirstName = m.User.FirstName,
                            LastName = m.User.LastName,
                            ProfilePictureUrl = m.User.ProfilePictureUrl,
                            IsAdmin = m.IsAdmin,
                            IsOwner = m.UserId == g.OwnerId,
                            IsOnline = m.User.IsOnline,
                            JoinedAt = m.JoinedAt
                        }).ToList(),
                        LastMessage = lastMessage != null ? new GroupMessageResponse
                        {
                            Id = lastMessage.Id,
                            GroupId = lastMessage.GroupId,
                            SenderId = lastMessage.SenderId,
                            SenderUsername = lastMessage.Sender.Username,
                            SenderProfilePictureUrl = lastMessage.Sender.ProfilePictureUrl,
                            Content = lastMessage.Content,
                            IsEdited = lastMessage.IsEdited,
                            EditedAt = lastMessage.EditedAt,
                            IsDeleted = lastMessage.IsDeleted,
                            DeletedAt = lastMessage.DeletedAt,
                            CreatedAt = lastMessage.CreatedAt
                        } : null,
                        UnreadCount = 0, // TODO: Implement read tracking for groups
                        CreatedAt = g.CreatedAt
                    };
                }).ToList();

                return Ok(groupResponses);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting groups");
                return StatusCode(500, new ErrorResponse { Message = "Error getting groups" });
            }
        }

        /// <summary>
        /// Create a new group
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<GroupResponse>> CreateGroup(CreateGroupRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                if (string.IsNullOrWhiteSpace(request.Name))
                    return BadRequest(new ErrorResponse { Message = "Group name is required" });

                if (request.MemberIds.Count < 1)
                    return BadRequest(new ErrorResponse { Message = "At least one member is required" });

                // Verify all members are friends
                foreach (var memberId in request.MemberIds)
                {
                    var areFriends = await _context.Friends
                        .AnyAsync(f => (f.UserId == userId && f.FriendUserId == memberId) ||
                                      (f.UserId == memberId && f.FriendUserId == userId));

                    if (!areFriends)
                        return BadRequest(new ErrorResponse { Message = "Can only add friends to groups" });
                }

                var group = new Group
                {
                    Name = request.Name,
                    Description = request.Description,
                    OwnerId = userId.Value,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Groups.Add(group);
                await _context.SaveChangesAsync();

                // Add creator as admin member
                var creatorMember = new GroupMember
                {
                    GroupId = group.Id,
                    UserId = userId.Value,
                    IsAdmin = true,
                    JoinedAt = DateTime.UtcNow
                };
                _context.GroupMembers.Add(creatorMember);

                // Add other members
                foreach (var memberId in request.MemberIds)
                {
                    if (memberId == userId.Value) continue; // Skip creator

                    var member = new GroupMember
                    {
                        GroupId = group.Id,
                        UserId = memberId,
                        IsAdmin = false,
                        JoinedAt = DateTime.UtcNow
                    };
                    _context.GroupMembers.Add(member);
                }

                await _context.SaveChangesAsync();

                // Load group with members
                var createdGroup = await _context.Groups
                    .Include(g => g.Owner)
                    .Include(g => g.Members)
                        .ThenInclude(m => m.User)
                    .FirstOrDefaultAsync(g => g.Id == group.Id);

                if (createdGroup == null)
                    return StatusCode(500, new ErrorResponse { Message = "Error creating group" });

                var response = new GroupResponse
                {
                    Id = createdGroup.Id,
                    Name = createdGroup.Name,
                    Description = createdGroup.Description,
                    GroupPictureUrl = createdGroup.GroupPictureUrl,
                    OwnerId = createdGroup.OwnerId,
                    OwnerUsername = createdGroup.Owner.Username,
                    Members = createdGroup.Members.Select(m => new GroupMemberResponse
                    {
                        UserId = m.UserId,
                        Username = m.User.Username,
                        FirstName = m.User.FirstName,
                        LastName = m.User.LastName,
                        ProfilePictureUrl = m.User.ProfilePictureUrl,
                        IsAdmin = m.IsAdmin,
                        IsOwner = m.UserId == createdGroup.OwnerId,
                        IsOnline = m.User.IsOnline,
                        JoinedAt = m.JoinedAt
                    }).ToList(),
                    CreatedAt = createdGroup.CreatedAt
                };

                // Notify all members via SignalR
                foreach (var member in createdGroup.Members)
                {
                    await _hubContext.Clients.User(member.UserId.ToString())
                        .SendAsync("GroupCreated", response);
                }

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating group");
                return StatusCode(500, new ErrorResponse { Message = "Error creating group" });
            }
        }

        /// <summary>
        /// Get group details
        /// </summary>
        [HttpGet("{groupId}")]
        public async Task<ActionResult<GroupResponse>> GetGroup(int groupId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                // Verify user is member
                var isMember = await _context.GroupMembers
                    .AnyAsync(gm => gm.GroupId == groupId && gm.UserId == userId);

                if (!isMember)
                    return Forbid();

                var group = await _context.Groups
                    .Include(g => g.Owner)
                    .Include(g => g.Members)
                        .ThenInclude(m => m.User)
                    .Include(g => g.Messages)
                        .ThenInclude(m => m.Sender)
                    .FirstOrDefaultAsync(g => g.Id == groupId);

                if (group == null)
                    return NotFound(new ErrorResponse { Message = "Group not found" });

                var lastMessage = group.Messages
                    .Where(m => !m.IsDeleted)
                    .OrderByDescending(m => m.CreatedAt)
                    .FirstOrDefault();

                var response = new GroupResponse
                {
                    Id = group.Id,
                    Name = group.Name,
                    Description = group.Description,
                    GroupPictureUrl = group.GroupPictureUrl,
                    OwnerId = group.OwnerId,
                    OwnerUsername = group.Owner.Username,
                    Members = group.Members.Select(m => new GroupMemberResponse
                    {
                        UserId = m.UserId,
                        Username = m.User.Username,
                        FirstName = m.User.FirstName,
                        LastName = m.User.LastName,
                        ProfilePictureUrl = m.User.ProfilePictureUrl,
                        IsAdmin = m.IsAdmin,
                        IsOwner = m.UserId == group.OwnerId,
                        IsOnline = m.User.IsOnline,
                        JoinedAt = m.JoinedAt
                    }).ToList(),
                    LastMessage = lastMessage != null ? new GroupMessageResponse
                    {
                        Id = lastMessage.Id,
                        GroupId = lastMessage.GroupId,
                        SenderId = lastMessage.SenderId,
                        SenderUsername = lastMessage.Sender.Username,
                        SenderProfilePictureUrl = lastMessage.Sender.ProfilePictureUrl,
                        Content = lastMessage.Content,
                        IsEdited = lastMessage.IsEdited,
                        EditedAt = lastMessage.EditedAt,
                        IsDeleted = lastMessage.IsDeleted,
                        DeletedAt = lastMessage.DeletedAt,
                        CreatedAt = lastMessage.CreatedAt
                    } : null,
                    UnreadCount = 0,
                    CreatedAt = group.CreatedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting group");
                return StatusCode(500, new ErrorResponse { Message = "Error getting group" });
            }
        }

        /// <summary>
        /// Get group messages
        /// </summary>
        [HttpGet("{groupId}/messages")]
        public async Task<ActionResult<List<GroupMessageResponse>>> GetGroupMessages(int groupId, [FromQuery] int? beforeId = null, [FromQuery] int limit = 50)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                // Verify user is member
                var isMember = await _context.GroupMembers
                    .AnyAsync(gm => gm.GroupId == groupId && gm.UserId == userId);

                if (!isMember)
                    return Forbid();

                var query = _context.GroupMessages
                    .Include(m => m.Sender)
                    .Where(m => m.GroupId == groupId && !m.IsDeleted);

                if (beforeId.HasValue)
                {
                    query = query.Where(m => m.Id < beforeId.Value);
                }

                var messages = await query
                    .OrderByDescending(m => m.CreatedAt)
                    .Take(limit)
                    .ToListAsync();

                var messageResponses = messages.Select(m => new GroupMessageResponse
                {
                    Id = m.Id,
                    GroupId = m.GroupId,
                    SenderId = m.SenderId,
                    SenderUsername = m.Sender.Username,
                    SenderProfilePictureUrl = m.Sender.ProfilePictureUrl,
                    Content = m.Content,
                    IsEdited = m.IsEdited,
                    EditedAt = m.EditedAt,
                    IsDeleted = m.IsDeleted,
                    DeletedAt = m.DeletedAt,
                    CreatedAt = m.CreatedAt
                }).Reverse().ToList();

                return Ok(messageResponses);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting group messages");
                return StatusCode(500, new ErrorResponse { Message = "Error getting messages" });
            }
        }

        /// <summary>
        /// Send a group message
        /// </summary>
        [HttpPost("{groupId}/messages")]
        public async Task<ActionResult<GroupMessageResponse>> SendGroupMessage(int groupId, SendGroupMessageRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                if (string.IsNullOrWhiteSpace(request.Content))
                    return BadRequest(new ErrorResponse { Message = "Message content is required" });

                // Verify user is member
                var isMember = await _context.GroupMembers
                    .AnyAsync(gm => gm.GroupId == groupId && gm.UserId == userId);

                if (!isMember)
                    return BadRequest(new ErrorResponse { Message = "You are not a member of this group" });

                var message = new GroupMessage
                {
                    GroupId = groupId,
                    SenderId = userId.Value,
                    Content = request.Content,
                    CreatedAt = DateTime.UtcNow
                };

                _context.GroupMessages.Add(message);
                await _context.SaveChangesAsync();

                var sender = await _context.Users.FindAsync(userId.Value);

                var response = new GroupMessageResponse
                {
                    Id = message.Id,
                    GroupId = message.GroupId,
                    SenderId = message.SenderId,
                    SenderUsername = sender?.Username ?? "",
                    SenderProfilePictureUrl = sender?.ProfilePictureUrl,
                    Content = message.Content,
                    IsEdited = message.IsEdited,
                    EditedAt = message.EditedAt,
                    IsDeleted = message.IsDeleted,
                    DeletedAt = message.DeletedAt,
                    CreatedAt = message.CreatedAt
                };

                // Send via SignalR to all group members
                var memberIds = await _context.GroupMembers
                    .Where(gm => gm.GroupId == groupId)
                    .Select(gm => gm.UserId.ToString())
                    .ToListAsync();

                foreach (var memberId in memberIds)
                {
                    await _hubContext.Clients.User(memberId)
                        .SendAsync("ReceiveGroupMessage", response);
                }

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending group message");
                return StatusCode(500, new ErrorResponse { Message = "Error sending message" });
            }
        }

        /// <summary>
        /// Add member to group
        /// </summary>
        [HttpPost("{groupId}/members")]
        public async Task<ActionResult<GroupMemberResponse>> AddMember(int groupId, AddGroupMemberRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                // Verify user is admin
                var isAdmin = await _context.GroupMembers
                    .AnyAsync(gm => gm.GroupId == groupId && gm.UserId == userId && gm.IsAdmin);

                if (!isAdmin)
                    return Forbid();

                // Verify they are friends
                var areFriends = await _context.Friends
                    .AnyAsync(f => (f.UserId == userId && f.FriendUserId == request.UserId) ||
                                  (f.UserId == request.UserId && f.FriendUserId == userId));

                if (!areFriends)
                    return BadRequest(new ErrorResponse { Message = "Can only add friends to groups" });

                // Check if already member
                var alreadyMember = await _context.GroupMembers
                    .AnyAsync(gm => gm.GroupId == groupId && gm.UserId == request.UserId);

                if (alreadyMember)
                    return BadRequest(new ErrorResponse { Message = "User is already a member" });

                var member = new GroupMember
                {
                    GroupId = groupId,
                    UserId = request.UserId,
                    IsAdmin = false,
                    JoinedAt = DateTime.UtcNow
                };

                _context.GroupMembers.Add(member);
                await _context.SaveChangesAsync();

                var user = await _context.Users.FindAsync(request.UserId);
                var group = await _context.Groups.FindAsync(groupId);

                var response = new GroupMemberResponse
                {
                    UserId = member.UserId,
                    Username = user?.Username ?? "",
                    FirstName = user?.FirstName,
                    LastName = user?.LastName,
                    ProfilePictureUrl = user?.ProfilePictureUrl,
                    IsAdmin = member.IsAdmin,
                    IsOwner = member.UserId == group?.OwnerId,
                    IsOnline = user?.IsOnline ?? false,
                    JoinedAt = member.JoinedAt
                };

                // Notify all members
                var memberIds = await _context.GroupMembers
                    .Where(gm => gm.GroupId == groupId)
                    .Select(gm => gm.UserId.ToString())
                    .ToListAsync();

                foreach (var memberId in memberIds)
                {
                    await _hubContext.Clients.User(memberId)
                        .SendAsync("GroupMemberAdded", groupId, response);
                }

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding member");
                return StatusCode(500, new ErrorResponse { Message = "Error adding member" });
            }
        }

        /// <summary>
        /// Remove member from group
        /// </summary>
        [HttpDelete("{groupId}/members/{memberId}")]
        public async Task<IActionResult> RemoveMember(int groupId, int memberId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var group = await _context.Groups.FindAsync(groupId);
                if (group == null)
                    return NotFound(new ErrorResponse { Message = "Group not found" });

                // Allow if admin or removing self
                var isAdmin = await _context.GroupMembers
                    .AnyAsync(gm => gm.GroupId == groupId && gm.UserId == userId && gm.IsAdmin);

                if (!isAdmin && userId != memberId)
                    return Forbid();

                // Can't remove owner
                if (memberId == group.OwnerId)
                    return BadRequest(new ErrorResponse { Message = "Cannot remove group owner" });

                var member = await _context.GroupMembers
                    .FirstOrDefaultAsync(gm => gm.GroupId == groupId && gm.UserId == memberId);

                if (member == null)
                    return NotFound(new ErrorResponse { Message = "Member not found" });

                _context.GroupMembers.Remove(member);
                await _context.SaveChangesAsync();

                // Notify all members
                var memberIds = await _context.GroupMembers
                    .Where(gm => gm.GroupId == groupId)
                    .Select(gm => gm.UserId.ToString())
                    .ToListAsync();

                foreach (var mid in memberIds)
                {
                    await _hubContext.Clients.User(mid)
                        .SendAsync("GroupMemberRemoved", groupId, memberId);
                }

                // Also notify removed member
                await _hubContext.Clients.User(memberId.ToString())
                    .SendAsync("GroupMemberRemoved", groupId, memberId);

                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing member");
                return StatusCode(500, new ErrorResponse { Message = "Error removing member" });
            }
        }

        /// <summary>
        /// Update group
        /// </summary>
        [HttpPut("{groupId}")]
        public async Task<ActionResult<GroupResponse>> UpdateGroup(int groupId, UpdateGroupRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                // Verify user is admin
                var isAdmin = await _context.GroupMembers
                    .AnyAsync(gm => gm.GroupId == groupId && gm.UserId == userId && gm.IsAdmin);

                if (!isAdmin)
                    return Forbid();

                var group = await _context.Groups.FindAsync(groupId);
                if (group == null)
                    return NotFound(new ErrorResponse { Message = "Group not found" });

                if (!string.IsNullOrWhiteSpace(request.Name))
                    group.Name = request.Name;

                if (request.Description != null)
                    group.Description = request.Description;

                await _context.SaveChangesAsync();

                // Load full group
                var updatedGroup = await _context.Groups
                    .Include(g => g.Owner)
                    .Include(g => g.Members)
                        .ThenInclude(m => m.User)
                    .FirstOrDefaultAsync(g => g.Id == groupId);

                if (updatedGroup == null)
                    return NotFound();

                var response = new GroupResponse
                {
                    Id = updatedGroup.Id,
                    Name = updatedGroup.Name,
                    Description = updatedGroup.Description,
                    GroupPictureUrl = updatedGroup.GroupPictureUrl,
                    OwnerId = updatedGroup.OwnerId,
                    OwnerUsername = updatedGroup.Owner.Username,
                    Members = updatedGroup.Members.Select(m => new GroupMemberResponse
                    {
                        UserId = m.UserId,
                        Username = m.User.Username,
                        FirstName = m.User.FirstName,
                        LastName = m.User.LastName,
                        ProfilePictureUrl = m.User.ProfilePictureUrl,
                        IsAdmin = m.IsAdmin,
                        IsOwner = m.UserId == updatedGroup.OwnerId,
                        IsOnline = m.User.IsOnline,
                        JoinedAt = m.JoinedAt
                    }).ToList(),
                    CreatedAt = updatedGroup.CreatedAt
                };

                // Notify all members
                var memberIds = await _context.GroupMembers
                    .Where(gm => gm.GroupId == groupId)
                    .Select(gm => gm.UserId.ToString())
                    .ToListAsync();

                foreach (var memberId in memberIds)
                {
                    await _hubContext.Clients.User(memberId)
                        .SendAsync("GroupUpdated", response);
                }

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating group");
                return StatusCode(500, new ErrorResponse { Message = "Error updating group" });
            }
        }

        /// <summary>
        /// Edit a group message
        /// </summary>
        [HttpPut("{groupId}/messages/{messageId}")]
        public async Task<ActionResult<GroupMessageResponse>> EditGroupMessage(int groupId, int messageId, [FromBody] SendGroupMessageRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                if (string.IsNullOrWhiteSpace(request.Content))
                    return BadRequest(new ErrorResponse { Message = "Message content is required" });

                var message = await _context.GroupMessages
                    .Include(m => m.Sender)
                    .FirstOrDefaultAsync(m => m.Id == messageId && m.GroupId == groupId);

                if (message == null)
                    return NotFound(new ErrorResponse { Message = "Message not found" });

                // Only sender can edit
                if (message.SenderId != userId)
                    return Forbid();

                message.Content = request.Content;
                message.IsEdited = true;
                message.EditedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                var response = new GroupMessageResponse
                {
                    Id = message.Id,
                    GroupId = message.GroupId,
                    SenderId = message.SenderId,
                    SenderUsername = message.Sender.Username,
                    SenderProfilePictureUrl = message.Sender.ProfilePictureUrl,
                    Content = message.Content,
                    IsEdited = message.IsEdited,
                    EditedAt = message.EditedAt,
                    IsDeleted = message.IsDeleted,
                    DeletedAt = message.DeletedAt,
                    CreatedAt = message.CreatedAt
                };

                // Notify all group members
                var memberIds = await _context.GroupMembers
                    .Where(gm => gm.GroupId == groupId)
                    .Select(gm => gm.UserId.ToString())
                    .ToListAsync();

                foreach (var memberId in memberIds)
                {
                    await _hubContext.Clients.User(memberId)
                        .SendAsync("GroupMessageEdited", response);
                }

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error editing group message");
                return StatusCode(500, new ErrorResponse { Message = "Error editing message" });
            }
        }

        /// <summary>
        /// Delete a group message
        /// </summary>
        [HttpDelete("{groupId}/messages/{messageId}")]
        public async Task<IActionResult> DeleteGroupMessage(int groupId, int messageId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var message = await _context.GroupMessages
                    .Include(m => m.Sender)
                    .FirstOrDefaultAsync(m => m.Id == messageId && m.GroupId == groupId);

                if (message == null)
                    return NotFound(new ErrorResponse { Message = "Message not found" });

                // Only sender can delete
                if (message.SenderId != userId)
                    return Forbid();

                message.Content = "[message deleted]";
                message.IsDeleted = true;
                message.DeletedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                var response = new GroupMessageResponse
                {
                    Id = message.Id,
                    GroupId = message.GroupId,
                    SenderId = message.SenderId,
                    SenderUsername = message.Sender.Username,
                    SenderProfilePictureUrl = message.Sender.ProfilePictureUrl,
                    Content = message.Content,
                    IsEdited = message.IsEdited,
                    EditedAt = message.EditedAt,
                    IsDeleted = message.IsDeleted,
                    DeletedAt = message.DeletedAt,
                    CreatedAt = message.CreatedAt
                };

                // Notify all group members
                var memberIds = await _context.GroupMembers
                    .Where(gm => gm.GroupId == groupId)
                    .Select(gm => gm.UserId.ToString())
                    .ToListAsync();

                foreach (var memberId in memberIds)
                {
                    await _hubContext.Clients.User(memberId)
                        .SendAsync("GroupMessageDeleted", response);
                }

                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting group message");
                return StatusCode(500, new ErrorResponse { Message = "Error deleting message" });
            }
        }

        /// <summary>
        /// Delete group
        /// </summary>
        [HttpDelete("{groupId}")]
        public async Task<IActionResult> DeleteGroup(int groupId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var group = await _context.Groups.FindAsync(groupId);
                if (group == null)
                    return NotFound(new ErrorResponse { Message = "Group not found" });

                // Only owner can delete
                if (group.OwnerId != userId)
                    return Forbid();

                // Get member IDs before deleting
                var memberIds = await _context.GroupMembers
                    .Where(gm => gm.GroupId == groupId)
                    .Select(gm => gm.UserId.ToString())
                    .ToListAsync();

                _context.Groups.Remove(group);
                await _context.SaveChangesAsync();

                // Notify all members
                foreach (var memberId in memberIds)
                {
                    await _hubContext.Clients.User(memberId)
                        .SendAsync("GroupDeleted", groupId);
                }

                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting group");
                return StatusCode(500, new ErrorResponse { Message = "Error deleting group" });
            }
        }
    }
}
