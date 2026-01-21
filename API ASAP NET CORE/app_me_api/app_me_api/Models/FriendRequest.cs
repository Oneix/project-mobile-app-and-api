using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace app_me_api.Models
{
    public enum FriendRequestStatus
    {
        Pending,
        Accepted,
        Rejected
    }

    public class FriendRequest : BaseEntity
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
        public FriendRequestStatus Status { get; set; } = FriendRequestStatus.Pending;
    }
}
