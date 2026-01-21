import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const bool _useSharedPrefs = true; // Use SharedPreferences on Windows due to FlutterSecureStorage issues
  
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
    print('TokenStorage.saveAuthData(): Saving token for user $username (userId: $userId)');
    
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setInt(_keyUserId, userId);
      await prefs.setString(_keyUsername, username);
      await prefs.setString(_keyEmail, email);
      if (firstName != null) await prefs.setString(_keyFirstName, firstName);
      if (lastName != null) await prefs.setString(_keyLastName, lastName);
      await prefs.setString(_keyExpiresAt, expiresAt.toIso8601String());
      print('TokenStorage.saveAuthData(): Token saved successfully (SharedPreferences)');
    } else {
      await Future.wait([
        _storage.write(key: _keyToken, value: token),
        _storage.write(key: _keyUserId, value: userId.toString()),
        _storage.write(key: _keyUsername, value: username),
        _storage.write(key: _keyEmail, value: email),
        if (firstName != null) _storage.write(key: _keyFirstName, value: firstName),
        if (lastName != null) _storage.write(key: _keyLastName, value: lastName),
        _storage.write(key: _keyExpiresAt, value: expiresAt.toIso8601String()),
      ]);
      print('TokenStorage.saveAuthData(): Token saved successfully (FlutterSecureStorage)');
    }
  }
  
  // Get token
  static Future<String?> getToken() async {
    final String? token;
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(_keyToken);
    } else {
      token = await _storage.read(key: _keyToken);
    }
    print('TokenStorage.getToken(): ${token != null ? "Token found (${token.length} chars)" : "Token is NULL"}');
    return token;
  }
  
  // Get user ID
  static Future<int?> getUserId() async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUserId);
    } else {
      final userId = await _storage.read(key: _keyUserId);
      return userId != null ? int.tryParse(userId) : null;
    }
  }
  
  // Get username
  static Future<String?> getUsername() async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUsername);
    } else {
      return await _storage.read(key: _keyUsername);
    }
  }
  
  // Get email
  static Future<String?> getEmail() async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyEmail);
    } else {
      return await _storage.read(key: _keyEmail);
    }
  }
  
  // Get first name
  static Future<String?> getFirstName() async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyFirstName);
    } else {
      return await _storage.read(key: _keyFirstName);
    }
  }
  
  // Get last name
  static Future<String?> getLastName() async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLastName);
    } else {
      return await _storage.read(key: _keyLastName);
    }
  }
  
  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    final String? expiresAtStr;
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      expiresAtStr = prefs.getString(_keyExpiresAt);
    } else {
      expiresAtStr = await _storage.read(key: _keyExpiresAt);
    }
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
    if (token == null) {
      print('TokenStorage.isLoggedIn(): No token found');
      return false;
    }
    
    final expired = await isTokenExpired();
    print('TokenStorage.isLoggedIn(): Token found, expired=$expired');
    return !expired;
  }
  
  // Clear all auth data (logout)
  static Future<void> clearAuthData() async {
    if (_useSharedPrefs) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      await _storage.deleteAll();
    }
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
