using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BCrypt.Net;
using app_me_api.Data;
using app_me_api.DTOs;
using app_me_api.Models;

namespace app_me_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            ApplicationDbContext context,
            IConfiguration configuration,
            ILogger<AuthController> logger)
        {
            _context = context;
            _configuration = configuration;
            _logger = logger;
        }

        [HttpPost("register")]
        public async Task<ActionResult<AuthResponse>> Register(RegisterRequest request)
        {
            try
            {
                // Check if user already exists
                if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                {
                    return BadRequest(new ErrorResponse 
                    { 
                        Message = "User with this email already exists" 
                    });
                }

                if (await _context.Users.AnyAsync(u => u.Username == request.Username))
                {
                    return BadRequest(new ErrorResponse 
                    { 
                        Message = "Username is already taken" 
                    });
                }

                // Hash password
                var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

                // Create new user
                var user = new User
                {
                    Username = request.Username,
                    Email = request.Email,
                    PasswordHash = passwordHash,
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                _logger.LogInformation($"New user registered: {user.Email}");

                // Generate JWT token
                var token = GenerateJwtToken(user);
                var expiryMinutes = int.Parse(_configuration["JwtSettings:ExpiryInMinutes"] ?? "1440");

                return Ok(new AuthResponse
                {
                    UserId = user.Id,
                    Username = user.Username,
                    Email = user.Email,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    Token = token,
                    ExpiresAt = DateTime.UtcNow.AddMinutes(expiryMinutes)
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during user registration");
                return StatusCode(500, new ErrorResponse 
                { 
                    Message = "An error occurred during registration" 
                });
            }
        }

        [HttpPost("login")]
        public async Task<ActionResult<AuthResponse>> Login(LoginRequest request)
        {
            try
            {
                // Find user by email
                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.Email == request.Email);

                if (user == null)
                {
                    return Unauthorized(new ErrorResponse 
                    { 
                        Message = "Invalid email or password" 
                    });
                }

                // Verify password
                if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                {
                    return Unauthorized(new ErrorResponse 
                    { 
                        Message = "Invalid email or password" 
                    });
                }

                // Update last seen
                user.LastSeenAt = DateTime.UtcNow;
                user.IsOnline = true;
                await _context.SaveChangesAsync();

                _logger.LogInformation($"User logged in: {user.Email}");

                // Generate JWT token
                var token = GenerateJwtToken(user);
                var expiryMinutes = int.Parse(_configuration["JwtSettings:ExpiryInMinutes"] ?? "1440");

                return Ok(new AuthResponse
                {
                    UserId = user.Id,
                    Username = user.Username,
                    Email = user.Email,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    Token = token,
                    ExpiresAt = DateTime.UtcNow.AddMinutes(expiryMinutes)
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during user login");
                return StatusCode(500, new ErrorResponse 
                { 
                    Message = "An error occurred during login" 
                });
            }
        }

        private string GenerateJwtToken(User user)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey not configured");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.UniqueName, user.Username),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var expiryMinutes = int.Parse(jwtSettings["ExpiryInMinutes"] ?? "1440");

            var token = new JwtSecurityToken(
                issuer: jwtSettings["Issuer"],
                audience: jwtSettings["Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
