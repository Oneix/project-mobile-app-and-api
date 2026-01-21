namespace app_me_api.DTOs
{
    public class CreateGroupRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<int> MemberIds { get; set; } = new();
    }

    public class AddGroupMemberRequest
    {
        public int UserId { get; set; }
    }

    public class UpdateGroupRequest
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
    }

    public class GroupResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? GroupPictureUrl { get; set; }
        public int OwnerId { get; set; }
        public string OwnerUsername { get; set; } = string.Empty;
        public List<GroupMemberResponse> Members { get; set; } = new();
        public GroupMessageResponse? LastMessage { get; set; }
        public int UnreadCount { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class GroupMemberResponse
    {
        public int UserId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public bool IsAdmin { get; set; }
        public bool IsOwner { get; set; }
        public bool IsOnline { get; set; }
        public DateTime JoinedAt { get; set; }
    }

    public class GroupMessageResponse
    {
        public int Id { get; set; }
        public int GroupId { get; set; }
        public int SenderId { get; set; }
        public string SenderUsername { get; set; } = string.Empty;
        public string? SenderProfilePictureUrl { get; set; }
        public string Content { get; set; } = string.Empty;
        public bool IsEdited { get; set; }
        public DateTime? EditedAt { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime? DeletedAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class SendGroupMessageRequest
    {
        public string Content { get; set; } = string.Empty;
    }
}
