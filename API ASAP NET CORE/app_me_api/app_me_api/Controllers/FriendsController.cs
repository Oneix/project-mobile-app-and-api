using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using app_me_api.Data;
using app_me_api.DTOs;
using app_me_api.Models;

namespace app_me_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FriendsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<FriendsController> _logger;

        public FriendsController(
            ApplicationDbContext context,
            ILogger<FriendsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Send friend request
        /// </summary>
        [HttpPost("request")]
        public async Task<ActionResult<FriendRequestResponse>> SendFriendRequest(FriendRequestDto request)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                if (string.IsNullOrEmpty(request.Username))
                    return BadRequest(new ErrorResponse { Message = "Username is required" });

                var receiver = await _context.Users
                    .FirstOrDefaultAsync(u => u.Username == request.Username);

                if (receiver == null)
                    return NotFound(new ErrorResponse { Message = "User not found" });

                if (receiver.Id == userId)
                    return BadRequest(new ErrorResponse { Message = "Cannot send friend request to yourself" });

                // Check if already friends
                var existingFriendship = await _context.Friends
                    .AnyAsync(f => (f.UserId == userId && f.FriendUserId == receiver.Id) ||
                                   (f.UserId == receiver.Id && f.FriendUserId == userId));

                if (existingFriendship)
                    return BadRequest(new ErrorResponse { Message = "Already friends" });

                // Check if request already exists
                var existingRequest = await _context.FriendRequests
                    .FirstOrDefaultAsync(fr => 
                        ((fr.SenderId == userId && fr.ReceiverId == receiver.Id) ||
                         (fr.SenderId == receiver.Id && fr.ReceiverId == userId)) &&
                        fr.Status == FriendRequestStatus.Pending);

                if (existingRequest != null)
                    return BadRequest(new ErrorResponse { Message = "Friend request already exists" });

                var friendRequest = new FriendRequest
                {
                    SenderId = userId.Value,
                    ReceiverId = receiver.Id,
                    Status = FriendRequestStatus.Pending
                };

                _context.FriendRequests.Add(friendRequest);
                await _context.SaveChangesAsync();

                var sender = await _context.Users.FindAsync(userId);

                return Ok(new FriendRequestResponse
                {
                    Id = friendRequest.Id,
                    SenderId = friendRequest.SenderId,
                    SenderUsername = sender!.Username,
                    SenderFirstName = sender.FirstName,
                    SenderLastName = sender.LastName,
                    SenderProfilePictureUrl = sender.ProfilePictureUrl,
                    ReceiverId = friendRequest.ReceiverId,
                    ReceiverUsername = receiver.Username,
                    Status = friendRequest.Status.ToString(),
                    CreatedAt = friendRequest.CreatedAt
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending friend request");
                return StatusCode(500, new ErrorResponse { Message = "Error sending friend request" });
            }
        }

        /// <summary>
        /// Get pending friend requests (received)
        /// </summary>
        [HttpGet("requests/pending")]
        public async Task<ActionResult<List<FriendRequestResponse>>> GetPendingRequests()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var requests = await _context.FriendRequests
                    .Include(fr => fr.Sender)
                    .Where(fr => fr.ReceiverId == userId && fr.Status == FriendRequestStatus.Pending)
                    .OrderByDescending(fr => fr.CreatedAt)
                    .Select(fr => new FriendRequestResponse
                    {
                        Id = fr.Id,
                        SenderId = fr.SenderId,
                        SenderUsername = fr.Sender.Username,
                        SenderFirstName = fr.Sender.FirstName,
                        SenderLastName = fr.Sender.LastName,
                        SenderProfilePictureUrl = fr.Sender.ProfilePictureUrl,
                        ReceiverId = fr.ReceiverId,
                        ReceiverUsername = fr.Receiver.Username,
                        Status = fr.Status.ToString(),
                        CreatedAt = fr.CreatedAt
                    })
                    .ToListAsync();

                return Ok(requests);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching pending requests");
                return StatusCode(500, new ErrorResponse { Message = "Error fetching requests" });
            }
        }

        /// <summary>
        /// Accept friend request
        /// </summary>
        [HttpPost("request/{requestId}/accept")]
        public async Task<ActionResult> AcceptFriendRequest(int requestId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var friendRequest = await _context.FriendRequests
                    .FirstOrDefaultAsync(fr => fr.Id == requestId && fr.ReceiverId == userId);

                if (friendRequest == null)
                    return NotFound(new ErrorResponse { Message = "Friend request not found" });

                if (friendRequest.Status != FriendRequestStatus.Pending)
                    return BadRequest(new ErrorResponse { Message = "Request already processed" });

                friendRequest.Status = FriendRequestStatus.Accepted;

                // Create friendship (bidirectional)
                _context.Friends.Add(new Friend
                {
                    UserId = friendRequest.SenderId,
                    FriendUserId = friendRequest.ReceiverId
                });

                _context.Friends.Add(new Friend
                {
                    UserId = friendRequest.ReceiverId,
                    FriendUserId = friendRequest.SenderId
                });

                await _context.SaveChangesAsync();

                return Ok(new { message = "Friend request accepted" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error accepting friend request");
                return StatusCode(500, new ErrorResponse { Message = "Error accepting request" });
            }
        }

        /// <summary>
        /// Reject friend request
        /// </summary>
        [HttpPost("request/{requestId}/reject")]
        public async Task<ActionResult> RejectFriendRequest(int requestId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var friendRequest = await _context.FriendRequests
                    .FirstOrDefaultAsync(fr => fr.Id == requestId && fr.ReceiverId == userId);

                if (friendRequest == null)
                    return NotFound(new ErrorResponse { Message = "Friend request not found" });

                if (friendRequest.Status != FriendRequestStatus.Pending)
                    return BadRequest(new ErrorResponse { Message = "Request already processed" });

                friendRequest.Status = FriendRequestStatus.Rejected;
                await _context.SaveChangesAsync();

                return Ok(new { message = "Friend request rejected" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error rejecting friend request");
                return StatusCode(500, new ErrorResponse { Message = "Error rejecting request" });
            }
        }

        /// <summary>
        /// Get friends list
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<List<FriendResponse>>> GetFriends()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var friends = await _context.Friends
                    .Include(f => f.FriendUser)
                    .Where(f => f.UserId == userId)
                    .OrderBy(f => f.FriendUser.Username)
                    .Select(f => new FriendResponse
                    {
                        FriendshipId = f.Id,
                        UserId = f.FriendUser.Id,
                        Username = f.FriendUser.Username,
                        Email = f.FriendUser.Email,
                        FirstName = f.FriendUser.FirstName,
                        LastName = f.FriendUser.LastName,
                        ProfilePictureUrl = f.FriendUser.ProfilePictureUrl,
                        IsOnline = f.FriendUser.IsOnline,
                        LastSeenAt = f.FriendUser.LastSeenAt,
                        FriendsSince = f.CreatedAt
                    })
                    .ToListAsync();

                return Ok(friends);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching friends");
                return StatusCode(500, new ErrorResponse { Message = "Error fetching friends" });
            }
        }

        /// <summary>
        /// Unfriend a user
        /// </summary>
        [HttpDelete("{friendshipId}")]
        public async Task<ActionResult> Unfriend(int friendshipId)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                var friendship = await _context.Friends
                    .FirstOrDefaultAsync(f => f.Id == friendshipId && f.UserId == userId);

                if (friendship == null)
                    return NotFound(new ErrorResponse { Message = "Friendship not found" });

                // Remove both directions of friendship
                var reverseFriendship = await _context.Friends
                    .FirstOrDefaultAsync(f => f.UserId == friendship.FriendUserId && 
                                            f.FriendUserId == userId);

                _context.Friends.Remove(friendship);
                if (reverseFriendship != null)
                    _context.Friends.Remove(reverseFriendship);

                await _context.SaveChangesAsync();

                return Ok(new { message = "Friend removed" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error unfriending user");
                return StatusCode(500, new ErrorResponse { Message = "Error removing friend" });
            }
        }

        /// <summary>
        /// Search users
        /// </summary>
        [HttpGet("search")]
        public async Task<ActionResult<List<UserSearchResponse>>> SearchUsers([FromQuery] string query)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null) return Unauthorized(new ErrorResponse { Message = "Invalid token" });

                if (string.IsNullOrWhiteSpace(query) || query.Length < 2)
                    return BadRequest(new ErrorResponse { Message = "Search query must be at least 2 characters" });

                var users = await _context.Users
                    .Where(u => u.Id != userId && 
                               (u.Username.Contains(query) || 
                                (u.FirstName != null && u.FirstName.Contains(query)) ||
                                (u.LastName != null && u.LastName.Contains(query))))
                    .Take(20)
                    .ToListAsync();

                var friendIds = await _context.Friends
                    .Where(f => f.UserId == userId)
                    .Select(f => f.FriendUserId)
                    .ToListAsync();

                var pendingRequestUserIds = await _context.FriendRequests
                    .Where(fr => (fr.SenderId == userId || fr.ReceiverId == userId) && 
                                fr.Status == FriendRequestStatus.Pending)
                    .Select(fr => fr.SenderId == userId ? fr.ReceiverId : fr.SenderId)
                    .ToListAsync();

                var results = users.Select(u => new UserSearchResponse
                {
                    UserId = u.Id,
                    Username = u.Username,
                    FirstName = u.FirstName,
                    LastName = u.LastName,
                    ProfilePictureUrl = u.ProfilePictureUrl,
                    IsOnline = u.IsOnline,
                    IsFriend = friendIds.Contains(u.Id),
                    HasPendingRequest = pendingRequestUserIds.Contains(u.Id)
                }).ToList();

                return Ok(results);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching users");
                return StatusCode(500, new ErrorResponse { Message = "Error searching users" });
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
