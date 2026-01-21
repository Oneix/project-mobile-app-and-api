using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace app_me_api.Models
{
    public class Message : BaseEntity
    {
        [Required]
        public int SenderId { get; set; }

        [ForeignKey(nameof(SenderId))]
        public User Sender { get; set; } = null!;

        [Required]
        public int ReceiverId { get; set; }

        [ForeignKey(nameof(ReceiverId))]
        public User Receiver { get; set; } = null!;

        [Required]
        [MaxLength(5000)]
        public string Content { get; set; } = string.Empty;

        public bool IsRead { get; set; } = false;

        public DateTime? ReadAt { get; set; }

        public bool IsEdited { get; set; } = false;

        public DateTime? EditedAt { get; set; }

        public bool IsDeleted { get; set; } = false;

        public DateTime? DeletedAt { get; set; }
    }
}
