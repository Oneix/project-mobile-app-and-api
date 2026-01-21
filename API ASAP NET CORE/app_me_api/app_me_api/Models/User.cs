using System.ComponentModel.DataAnnotations;

namespace app_me_api.Models
{
    public class User : BaseEntity
    {
        [Required]
        [StringLength(100)]
        public string Username { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [StringLength(200)]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [StringLength(100)]
        public string? FirstName { get; set; }

        [StringLength(100)]
        public string? LastName { get; set; }

        [StringLength(500)]
        public string? ProfilePictureUrl { get; set; }

        public bool IsOnline { get; set; } = false;
        
        public DateTime? LastSeenAt { get; set; }

        // Navigation properties for future relationships
        // public ICollection<Chat> Chats { get; set; } = new List<Chat>();
        // public ICollection<Message> Messages { get; set; } = new List<Message>();
        // public ICollection<Friend> Friends { get; set; } = new List<Friend>();
    }
}
