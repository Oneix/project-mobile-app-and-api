using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;
using app_me_api.Data;
using Microsoft.EntityFrameworkCore;

namespace app_me_api.Hubs
{
    [Authorize]
    public class ChatHub : Hub
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ChatHub> _logger;

        public ChatHub(ApplicationDbContext context, ILogger<ChatHub> logger)
        {
            _context = context;
            _logger = logger;
        }

        public override async Task OnConnectedAsync()
        {
            var userId = GetCurrentUserId();
            if (userId.HasValue)
            {
                // Update user online status
                var user = await _context.Users.FindAsync(userId.Value);
                if (user != null)
                {
                    user.IsOnline = true;
                    user.LastSeenAt = DateTime.UtcNow;
                    await _context.SaveChangesAsync();

                    // Notify friends that user is online
                    var friendIds = await _context.Friends
                        .Where(f => f.UserId == userId.Value)
                        .Select(f => f.FriendUserId)
                        .ToListAsync();

                    foreach (var friendId in friendIds)
                    {
                        await Clients.User(friendId.ToString()).SendAsync("UserOnline", userId.Value);
                    }
                }

                _logger.LogInformation($"User {userId} connected to chat hub");
            }

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userId = GetCurrentUserId();
            if (userId.HasValue)
            {
                // Update user offline status
                var user = await _context.Users.FindAsync(userId.Value);
                if (user != null)
                {
                    user.IsOnline = false;
                    user.LastSeenAt = DateTime.UtcNow;
                    await _context.SaveChangesAsync();

                    // Notify friends that user is offline
                    var friendIds = await _context.Friends
                        .Where(f => f.UserId == userId.Value)
                        .Select(f => f.FriendUserId)
                        .ToListAsync();

                    foreach (var friendId in friendIds)
                    {
                        await Clients.User(friendId.ToString()).SendAsync("UserOffline", userId.Value, DateTime.UtcNow);
                    }
                }

                _logger.LogInformation($"User {userId} disconnected from chat hub");
            }

            await base.OnDisconnectedAsync(exception);
        }

        public async Task SendMessage(int receiverId, string content)
        {
            var senderId = GetCurrentUserId();
            if (!senderId.HasValue)
                return;

            _logger.LogInformation($"User {senderId} sending message to {receiverId}");

            // Verify they are friends
            var areFriends = await _context.Friends
                .AnyAsync(f => (f.UserId == senderId.Value && f.FriendUserId == receiverId) ||
                              (f.UserId == receiverId && f.FriendUserId == senderId.Value));

            if (!areFriends)
            {
                _logger.LogWarning($"User {senderId} tried to message non-friend {receiverId}");
                return;
            }

            // Send message to receiver
            await Clients.User(receiverId.ToString()).SendAsync("ReceiveMessage", senderId.Value, content);
        }

        public async Task MarkAsRead(int messageId)
        {
            var userId = GetCurrentUserId();
            if (!userId.HasValue)
                return;

            var message = await _context.Messages
                .FirstOrDefaultAsync(m => m.Id == messageId && m.ReceiverId == userId.Value);

            if (message != null && !message.IsRead)
            {
                message.IsRead = true;
                message.ReadAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();

                // Notify sender that message was read
                await Clients.User(message.SenderId.ToString()).SendAsync("MessageRead", messageId);
            }
        }

        public async Task Typing(int receiverId)
        {
            var senderId = GetCurrentUserId();
            if (!senderId.HasValue)
                return;

            await Clients.User(receiverId.ToString()).SendAsync("UserTyping", senderId.Value);
        }

        public async Task StopTyping(int receiverId)
        {
            var senderId = GetCurrentUserId();
            if (!senderId.HasValue)
                return;

            await Clients.User(receiverId.ToString()).SendAsync("UserStoppedTyping", senderId.Value);
        }

        private int? GetCurrentUserId()
        {
            var userIdClaim = Context.User?.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int userId))
            {
                return userId;
            }
            return null;
        }
    }
}
