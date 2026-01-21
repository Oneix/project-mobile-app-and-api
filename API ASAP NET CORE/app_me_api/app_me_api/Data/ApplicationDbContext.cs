using Microsoft.EntityFrameworkCore;
using app_me_api.Models;

namespace app_me_api.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Friend> Friends { get; set; }
        public DbSet<FriendRequest> FriendRequests { get; set; }
        public DbSet<Message> Messages { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User entity
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasIndex(e => e.Email).IsUnique();
                entity.HasIndex(e => e.Username).IsUnique();
                
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("CURRENT_TIMESTAMP");
            });

            // Configure Friend entity
            modelBuilder.Entity<Friend>(entity =>
            {
                entity.HasOne(f => f.User)
                    .WithMany()
                    .HasForeignKey(f => f.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(f => f.FriendUser)
                    .WithMany()
                    .HasForeignKey(f => f.FriendUserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasIndex(e => new { e.UserId, e.FriendUserId }).IsUnique();
            });

            // Configure FriendRequest entity
            modelBuilder.Entity<FriendRequest>(entity =>
            {
                entity.HasOne(fr => fr.Sender)
                    .WithMany()
                    .HasForeignKey(fr => fr.SenderId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(fr => fr.Receiver)
                    .WithMany()
                    .HasForeignKey(fr => fr.ReceiverId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasIndex(e => new { e.SenderId, e.ReceiverId, e.Status });
            });

            // Configure Message entity
            modelBuilder.Entity<Message>(entity =>
            {
                entity.HasOne(m => m.Sender)
                    .WithMany()
                    .HasForeignKey(m => m.SenderId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(m => m.Receiver)
                    .WithMany()
                    .HasForeignKey(m => m.ReceiverId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasIndex(e => new { e.SenderId, e.ReceiverId, e.CreatedAt });
                entity.HasIndex(e => e.CreatedAt);
            });
        }

        public override int SaveChanges()
        {
            UpdateTimestamps();
            return base.SaveChanges();
        }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateTimestamps();
            return base.SaveChangesAsync(cancellationToken);
        }

        private void UpdateTimestamps()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.Entity is BaseEntity && 
                           (e.State == EntityState.Modified));

            foreach (var entry in entries)
            {
                ((BaseEntity)entry.Entity).UpdatedAt = DateTime.UtcNow;
            }
        }
    }
}
