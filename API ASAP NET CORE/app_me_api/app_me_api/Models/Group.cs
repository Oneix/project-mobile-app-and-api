using System.ComponentModel.DataAnnotations;

namespace app_me_api.Models
{
    public class Group : BaseEntity
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Description { get; set; }

        public string? GroupPictureUrl { get; set; }

        public int OwnerId { get; set; }
        public User Owner { get; set; } = null!;

        // Navigation properties
        public ICollection<GroupMember> Members { get; set; } = new List<GroupMember>();
        public ICollection<GroupMessage> Messages { get; set; } = new List<GroupMessage>();
    }

    public class GroupMember : BaseEntity
    {
        public int GroupId { get; set; }
        public Group Group { get; set; } = null!;

        public int UserId { get; set; }
        public User User { get; set; } = null!;

        public bool IsAdmin { get; set; } = false;
        public DateTime JoinedAt { get; set; } = DateTime.UtcNow;
    }

    public class GroupMessage : BaseEntity
    {
        public int GroupId { get; set; }
        public Group Group { get; set; } = null!;

        public int SenderId { get; set; }
        public User Sender { get; set; } = null!;

        [Required]
        [MaxLength(5000)]
        public string Content { get; set; } = string.Empty;

        public bool IsEdited { get; set; } = false;
        public DateTime? EditedAt { get; set; }

        public bool IsDeleted { get; set; } = false;
        public DateTime? DeletedAt { get; set; }
    }
}
