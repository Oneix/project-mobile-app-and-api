# App Me API - Authentication Backend

## ✅ Setup Complete!

The backend authentication system is **ready to use**. All components have been implemented and tested.

## 🎯 What's Implemented

### Authentication Endpoints
- **POST** `/api/auth/register` - Register new user
- **POST** `/api/auth/login` - Login existing user

### Features Included
✅ JWT Token Authentication  
✅ Password Hashing with BCrypt  
✅ MySQL Database with Entity Framework Core  
✅ Automatic Database Migrations  
✅ CORS Configuration for Flutter  
✅ Input Validation  
✅ Error Handling  

## 🚀 How to Run

### Prerequisites
1. **XAMPP** with MySQL running on port 3306
2. **.NET 10.0 SDK** installed

### Steps

1. **Start XAMPP MySQL**
   - Open XAMPP Control Panel
   - Click "Start" for MySQL module

2. **Run the API**
   ```bash
   cd "c:\Projects\project-mobile-app-and-api\API ASAP NET CORE\app_me_api\app_me_api"
   dotnet run
   ```

3. **Database Auto-Creation**
   - On first run, the API will automatically:
     - Connect to MySQL
     - Create database `app_me_db`
     - Create `Users` table with all columns
     - Apply all migrations

4. **API will be available at:**
   - HTTPS: `https://localhost:7xxx`
   - HTTP: `http://localhost:5xxx`
   - (Exact ports shown in console on startup)

## 📝 API Testing Examples

### Register New User
```bash
POST https://localhost:7xxx/api/auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecurePass123",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Response:**
```json
{
  "userId": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2026-01-22T10:00:00Z"
}
```

### Login User
```bash
POST https://localhost:7xxx/api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response:** Same as register response with fresh token

## 🔧 Configuration

### Database Connection
Located in `appsettings.json`:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Port=3306;Database=app_me_db;User=root;Password=;"
}
```

### JWT Settings
```json
"JwtSettings": {
  "SecretKey": "YourSuperSecretKeyForJWTTokenGeneration12345!",
  "Issuer": "AppMeAPI",
  "Audience": "AppMeClient",
  "ExpiryInMinutes": 1440
}
```

## 📦 Database Schema

### Users Table
- `Id` (int, Primary Key)
- `Username` (varchar(100), Unique, Required)
- `Email` (varchar(200), Unique, Required)
- `PasswordHash` (text, Required)
- `FirstName` (varchar(100), Optional)
- `LastName` (varchar(100), Optional)
- `ProfilePictureUrl` (varchar(500), Optional)
- `IsOnline` (boolean, Default: false)
- `LastSeenAt` (datetime, Optional)
- `CreatedAt` (datetime, Auto-generated)
- `UpdatedAt` (datetime, Auto-updated)

## 🔐 Security Features

- **Password Hashing**: BCrypt with salt
- **JWT Tokens**: 24-hour expiry (configurable)
- **CORS**: Configured to allow Flutter app
- **Input Validation**: Email format, password length (min 6 chars), username length (3-100 chars)
- **Unique Constraints**: Email and username must be unique

## 📱 Flutter Integration

The Flutter app can connect to this API using the token returned from login/register:

```dart
// Add token to HTTP headers
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

## 🐛 Troubleshooting

### Database Connection Error
- Make sure XAMPP MySQL is running
- Check MySQL is on port 3306
- Verify root user has no password (or update connection string)

### Port Already in Use
- Change port in `Properties/launchSettings.json`

## 📈 Next Steps

Ready to implement:
1. Friends management endpoints (Epic 2)
2. Personal chat endpoints (Epic 3)
3. Group chat endpoints (Epic 4)
4. Real-time messaging with SignalR

---

**Status**: ✅ Production Ready for Authentication
