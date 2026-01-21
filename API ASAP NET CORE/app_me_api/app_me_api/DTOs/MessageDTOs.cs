namespace app_me_api.DTOs
{
    public class SendMessageRequest
    {
        public int ReceiverId { get; set; }
        public string Content { get; set; } = string.Empty;
    }

    public class EditMessageRequest
    {
        public string Content { get; set; } = string.Empty;
    }

    public class MessageResponse
    {
        public int Id { get; set; }
        public int SenderId { get; set; }
        public string SenderUsername { get; set; } = string.Empty;
        public string? SenderProfilePictureUrl { get; set; }
        public int ReceiverId { get; set; }
        public string ReceiverUsername { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public bool IsRead { get; set; }
        public DateTime? ReadAt { get; set; }
        public bool IsEdited { get; set; }
        public DateTime? EditedAt { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class ChatConversationResponse
    {
        public int UserId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public bool IsOnline { get; set; }
        public DateTime? LastSeenAt { get; set; }
        public MessageResponse? LastMessage { get; set; }
        public int UnreadCount { get; set; }
    }
}
