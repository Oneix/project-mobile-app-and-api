import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  
  // Keys
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyFirstName = 'first_name';
  static const String _keyLastName = 'last_name';
  static const String _keyExpiresAt = 'expires_at';
  
  // Save auth data
  static Future<void> saveAuthData({
    required String token,
    required int userId,
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    required DateTime expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _keyToken, value: token),
      _storage.write(key: _keyUserId, value: userId.toString()),
      _storage.write(key: _keyUsername, value: username),
      _storage.write(key: _keyEmail, value: email),
      if (firstName != null) _storage.write(key: _keyFirstName, value: firstName),
      if (lastName != null) _storage.write(key: _keyLastName, value: lastName),
      _storage.write(key: _keyExpiresAt, value: expiresAt.toIso8601String()),
    ]);
  }
  
  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }
  
  // Get user ID
  static Future<int?> getUserId() async {
    final userId = await _storage.read(key: _keyUserId);
    return userId != null ? int.tryParse(userId) : null;
  }
  
  // Get username
  static Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }
  
  // Get email
  static Future<String?> getEmail() async {
    return await _storage.read(key: _keyEmail);
  }
  
  // Get first name
  static Future<String?> getFirstName() async {
    return await _storage.read(key: _keyFirstName);
  }
  
  // Get last name
  static Future<String?> getLastName() async {
    return await _storage.read(key: _keyLastName);
  }
  
  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    final expiresAtStr = await _storage.read(key: _keyExpiresAt);
    if (expiresAtStr == null) return true;
    
    try {
      final expiresAt = DateTime.parse(expiresAtStr);
      return DateTime.now().isAfter(expiresAt);
    } catch (e) {
      return true;
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    
    final expired = await isTokenExpired();
    return !expired;
  }
  
  // Clear all auth data (logout)
  static Future<void> clearAuthData() async {
    await _storage.deleteAll();
  }
  
  // Get full user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final token = await getToken();
    if (token == null) return null;
    
    final userId = await getUserId();
    final username = await getUsername();
    final email = await getEmail();
    final firstName = await getFirstName();
    final lastName = await getLastName();
    
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
