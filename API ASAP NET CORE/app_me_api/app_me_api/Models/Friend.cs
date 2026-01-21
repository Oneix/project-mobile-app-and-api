using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace app_me_api.Models
{
    public class Friend : BaseEntity
    {
        [Required]
        public int UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public User User { get; set; } = null!;

        [Required]
        public int FriendUserId { get; set; }

        [ForeignKey(nameof(FriendUserId))]
        public User FriendUser { get; set; } = null!;
    }
}
