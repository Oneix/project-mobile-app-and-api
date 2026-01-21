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
    public class MessagesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<MessagesController> _logger;
        private readonly IHubContext<ChatHub> _hubContext;

        public MessagesController(
            ApplicationDbContext context,
            ILogger<MessagesController> logger,
            IHubContext<ChatHub> hubContext)
        {
            _context = context;
            _logger = logger;
            _hubContext = hubContext;
        }

        /// <summary>
        /// Get all conversations (users with whom you have exchanged messages)
        /// </summary>
        [HttpGet("conversations")]
        public async Task<ActionResult<List<ChatConversationResponse>>> GetConversations()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                _logger.LogInformation($"Getting conversations for user {userId}");

                // Get all users I've exchanged messages with
                var conversationUserIds = await _context.Messages
                    .Where(m => (m.SenderId == userId || m.ReceiverId == userId) && !m.IsDeleted)
                    .Select(m => m.SenderId == userId ? m.ReceiverId : m.SenderId)
                    .Distinct()
                    .ToListAsync();

                _logger.LogInformation($"Found {conversationUserIds.Count} conversation user IDs: {string.Join(", ", conversationUserIds)}");

                var conversations = new List<ChatConversationResponse>();

                foreach (var otherUserId in conversationUserIds)
                {
                    var user = await _context.Users.FindAsync(otherUserId);
                    if (user == null) continue;

                    // Get last message
                    var lastMessage = await _context.Messages
                        .Where(m => ((m.SenderId == userId && m.ReceiverId == otherUserId) ||
                                    (m.SenderId == otherUserId && m.ReceiverId == userId)) && !m.IsDeleted)
                        .OrderByDescending(m => m.CreatedAt)
                        .FirstOrDefaultAsync();

                    // Get unread count
                    var unreadCount = await _context.Messages
                        .CountAsync(m => m.SenderId == otherUserId && m.ReceiverId == userId && !m.IsRead && !m.IsDeleted);

                    MessageResponse? lastMessageResponse = null;
                    if (lastMessage != null)
                    {
                        var sender = await _context.Users.FindAsync(lastMessage.SenderId);
                        var receiver = await _context.Users.FindAsync(lastMessage.ReceiverId);

                        lastMessageResponse = new MessageResponse
                        {
                            Id = lastMessage.Id,
                            SenderId = lastMessage.SenderId,
                            SenderUsername = sender?.Username ?? "",
                            SenderProfilePictureUrl = sender?.ProfilePictureUrl,
                            ReceiverId = lastMessage.ReceiverId,
                            ReceiverUsername = receiver?.Username ?? "",
                            Content = lastMessage.Content,
                            IsRead = lastMessage.IsRead,
                            ReadAt = lastMessage.ReadAt,
                            IsEdited = lastMessage.IsEdited,
                            EditedAt = lastMessage.EditedAt,
                            IsDeleted = lastMessage.IsDeleted,
                            CreatedAt = lastMessage.CreatedAt
                        };
                    }

                    conversations.Add(new ChatConversationResponse
                    {
                        UserId = user.Id,
                        Username = user.Username,
                        FirstName = user.FirstName,
                        LastName = user.LastName,
                        ProfilePictureUrl = user.ProfilePictureUrl,
                        IsOnline = user.IsOnline,
                        LastSeenAt = user.LastSeenAt,
                        LastMessage = lastMessageResponse,
                        UnreadCount = unreadCount
                    });
                }

                // Sort by last message time
                conversations = conversations
                    .OrderByDescending(c => c.LastMessage?.CreatedAt ?? DateTime.MinValue)
                    .ToList();

                return Ok(conversations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching conversations");
                return StatusCode(500, new ErrorResponse { Message = "Error fetching conversations" });
            }
        }

        /// <summary>
        /// Get message history with a specific user
        /// </summary>
        [HttpGet("history/{otherUserId}")]
        public async Task<ActionResult<List<MessageResponse>>> GetMessageHistory(int otherUserId, [FromQuery] int? beforeId = null, [FromQuery] int limit = 50)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                // Verify they are friends
                var areFriends = await _context.Friends
                    .AnyAsync(f => (f.UserId == userId && f.FriendUserId == otherUserId) ||
                                  (f.UserId == otherUserId && f.FriendUserId == userId));

                if (!areFriends)
                    return BadRequest(new ErrorResponse { Message = "Can only message friends" });

                var query = _context.Messages
                    .Include(m => m.Sender)
                    .Include(m => m.Receiver)
                    .Where(m => ((m.SenderId == userId && m.ReceiverId == otherUserId) ||
                                (m.SenderId == otherUserId && m.ReceiverId == userId)) && !m.IsDeleted);

                if (beforeId.HasValue)
                {
                    query = query.Where(m => m.Id < beforeId.Value);
                }

                var messages = await query
                    .OrderByDescending(m => m.CreatedAt)
                    .Take(limit)
                    .ToListAsync();

                var messageResponses = messages.Select(m => new MessageResponse
                {
                    Id = m.Id,
                    SenderId = m.SenderId,
                    SenderUsername = m.Sender.Username,
                    SenderProfilePictureUrl = m.Sender.ProfilePictureUrl,
                    ReceiverId = m.ReceiverId,
                    ReceiverUsername = m.Receiver.Username,
                    Content = m.Content,
                    IsRead = m.IsRead,
                    ReadAt = m.ReadAt,
                    IsEdited = m.IsEdited,
                    EditedAt = m.EditedAt,
                    IsDeleted = m.IsDeleted,
                    CreatedAt = m.CreatedAt
                }).Reverse().ToList(); // Reverse to get chronological order

                return Ok(messageResponses);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching message history");
                return StatusCode(500, new ErrorResponse { Message = "Error fetching messages" });
            }
        }

        /// <summary>
        /// Send a message
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<MessageResponse>> SendMessage(SendMessageRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                if (string.IsNullOrWhiteSpace(request.Content))
                    return BadRequest(new ErrorResponse { Message = "Message content is required" });

                // Verify they are friends
                var areFriends = await _context.Friends
                    .AnyAsync(f => (f.UserId == userId && f.FriendUserId == request.ReceiverId) ||
                                  (f.UserId == request.ReceiverId && f.FriendUserId == userId));

                if (!areFriends)
                    return BadRequest(new ErrorResponse { Message = "Can only message friends" });

                var message = new Message
                {
                    SenderId = userId.Value,
                    ReceiverId = request.ReceiverId,
                    Content = request.Content.Trim()
                };

                _context.Messages.Add(message);
                await _context.SaveChangesAsync();

                var sender = await _context.Users.FindAsync(userId.Value);
                var receiver = await _context.Users.FindAsync(request.ReceiverId);

                var response = new MessageResponse
                {
                    Id = message.Id,
                    SenderId = message.SenderId,
                    SenderUsername = sender?.Username ?? "",
                    SenderProfilePictureUrl = sender?.ProfilePictureUrl,
                    ReceiverId = message.ReceiverId,
                    ReceiverUsername = receiver?.Username ?? "",
                    Content = message.Content,
                    IsRead = message.IsRead,
                    ReadAt = message.ReadAt,
                    IsEdited = message.IsEdited,
                    EditedAt = message.EditedAt,
                    IsDeleted = message.IsDeleted,
                    CreatedAt = message.CreatedAt
                };

                // Send via SignalR to receiver
                await _hubContext.Clients.User(request.ReceiverId.ToString())
                    .SendAsync("ReceiveMessage", response);

                // Also send to sender so their chat list updates
                await _hubContext.Clients.User(userId.Value.ToString())
                    .SendAsync("ReceiveMessage", response);

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending message");
                return StatusCode(500, new ErrorResponse { Message = "Error sending message" });
            }
        }

        /// <summary>
        /// Edit a message
        /// </summary>
        [HttpPut("{messageId}")]
        public async Task<ActionResult<MessageResponse>> EditMessage(int messageId, EditMessageRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                if (string.IsNullOrWhiteSpace(request.Content))
                    return BadRequest(new ErrorResponse { Message = "Message content is required" });

                var message = await _context.Messages
                    .Include(m => m.Sender)
                    .Include(m => m.Receiver)
                    .FirstOrDefaultAsync(m => m.Id == messageId && m.SenderId == userId);

                if (message == null)
                    return NotFound(new ErrorResponse { Message = "Message not found or you don't have permission" });

                if (message.IsDeleted)
                    return BadRequest(new ErrorResponse { Message = "Cannot edit deleted message" });

                message.Content = request.Content.Trim();
                message.IsEdited = true;
                message.EditedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                var response = new MessageResponse
                {
                    Id = message.Id,
                    SenderId = message.SenderId,
                    SenderUsername = message.Sender.Username,
                    SenderProfilePictureUrl = message.Sender.ProfilePictureUrl,
                    ReceiverId = message.ReceiverId,
                    ReceiverUsername = message.Receiver.Username,
                    Content = message.Content,
                    IsRead = message.IsRead,
                    ReadAt = message.ReadAt,
                    IsEdited = message.IsEdited,
                    EditedAt = message.EditedAt,
                    IsDeleted = message.IsDeleted,
                    CreatedAt = message.CreatedAt
                };

                // Notify via SignalR
                await _hubContext.Clients.User(message.ReceiverId.ToString())
                    .SendAsync("MessageEdited", response);

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error editing message");
                return StatusCode(500, new ErrorResponse { Message = "Error editing message" });
            }
        }

        /// <summary>
        /// Delete a message
        /// </summary>
        [HttpDelete("{messageId}")]
        public async Task<ActionResult> DeleteMessage(int messageId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var message = await _context.Messages
                    .FirstOrDefaultAsync(m => m.Id == messageId && m.SenderId == userId);

                if (message == null)
                    return NotFound(new ErrorResponse { Message = "Message not found or you don't have permission" });

                message.IsDeleted = true;
                message.DeletedAt = DateTime.UtcNow;
                message.Content = "[message deleted]";

                await _context.SaveChangesAsync();

                // Notify via SignalR
                await _hubContext.Clients.User(message.ReceiverId.ToString())
                    .SendAsync("MessageDeleted", messageId);

                return Ok(new { message = "Message deleted" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting message");
                return StatusCode(500, new ErrorResponse { Message = "Error deleting message" });
            }
        }

        /// <summary>
        /// Mark messages as read
        /// </summary>
        [HttpPost("mark-read/{otherUserId}")]
        public async Task<ActionResult> MarkMessagesAsRead(int otherUserId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var unreadMessages = await _context.Messages
                    .Where(m => m.SenderId == otherUserId && m.ReceiverId == userId && !m.IsRead)
                    .ToListAsync();

                foreach (var message in unreadMessages)
                {
                    message.IsRead = true;
                    message.ReadAt = DateTime.UtcNow;
                }

                await _context.SaveChangesAsync();

                // Notify sender via SignalR
                await _hubContext.Clients.User(otherUserId.ToString())
                    .SendAsync("MessagesRead", userId.Value, unreadMessages.Select(m => m.Id).ToList());

                return Ok(new { message = "Messages marked as read" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error marking messages as read");
                return StatusCode(500, new ErrorResponse { Message = "Error marking messages as read" });
            }
        }

        private int? GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int userId))
            {
                return userId;
            }
            return null;
        }
    }
}
