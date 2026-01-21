using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using app_me_api.Data;
using app_me_api.DTOs;

namespace app_me_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UserController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<UserController> _logger;

        public UserController(
            ApplicationDbContext context,
            ILogger<UserController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// get current user profile
        /// </summary>
        /// <remarks>
        /// returns the profile information of the currently logged in user. you need to include the jwt token in the authorization header.
        /// </remarks>
        [HttpGet("profile")]
        public async Task<ActionResult<UserProfileResponse>> GetProfile()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null)
                {
                    return Unauthorized(new ErrorResponse { Message = "Invalid token" });
                }

                var user = await _context.Users.FindAsync(userId);
                if (user == null)
                {
                    return NotFound(new ErrorResponse { Message = "User not found" });
                }

                var profile = new UserProfileResponse
                {
                    UserId = user.Id,
                    Username = user.Username,
                    Email = user.Email,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    ProfilePictureUrl = user.ProfilePictureUrl,
                    IsOnline = user.IsOnline,
                    LastSeenAt = user.LastSeenAt,
                    CreatedAt = user.CreatedAt
                };

                return Ok(profile);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching user profile");
                return StatusCode(500, new ErrorResponse { Message = "Error fetching profile" });
            }
        }

        /// <summary>
        /// update current user profile
        /// </summary>
        /// <remarks>
        /// updates the profile information like first name, last name, and profile picture url. requires jwt token in authorization header.
        /// </remarks>
        [HttpPut("profile")]
        public async Task<ActionResult<UserProfileResponse>> UpdateProfile(UpdateProfileRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null)
                {
                    return Unauthorized(new ErrorResponse { Message = "Invalid token" });
                }

                var user = await _context.Users.FindAsync(userId);
                if (user == null)
                {
                    return NotFound(new ErrorResponse { Message = "User not found" });
                }

                // Update fields if provided
                if (request.FirstName != null)
                    user.FirstName = request.FirstName;

                if (request.LastName != null)
                    user.LastName = request.LastName;

                if (request.ProfilePictureUrl != null)
                    user.ProfilePictureUrl = request.ProfilePictureUrl;

                user.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation($"User profile updated: {user.Email}");

                var profile = new UserProfileResponse
                {
                    UserId = user.Id,
                    Username = user.Username,
                    Email = user.Email,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    ProfilePictureUrl = user.ProfilePictureUrl,
                    IsOnline = user.IsOnline,
                    LastSeenAt = user.LastSeenAt,
                    CreatedAt = user.CreatedAt
                };

                return Ok(profile);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user profile");
                return StatusCode(500, new ErrorResponse { Message = "Error updating profile" });
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
