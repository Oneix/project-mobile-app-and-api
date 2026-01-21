import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/token_storage.dart';

class AuthResponse {
  final int userId;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String token;
  final DateTime expiresAt;

  AuthResponse({
    required this.userId,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.token,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

class AuthService {
  // Register new user
  static Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');
      
      final body = {
        'username': username,
        'email': email,
        'password': password,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
      };

      final response = await http
          .post(
            url,
            headers: ApiConstants.headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        
        // Save auth data to secure storage
        await TokenStorage.saveAuthData(
          token: authResponse.token,
          userId: authResponse.userId,
          username: authResponse.username,
          email: authResponse.email,
          firstName: authResponse.firstName,
          lastName: authResponse.lastName,
          expiresAt: authResponse.expiresAt,
        );
        
        return authResponse;
      } else {
        // Handle error responses
        if (response.body.isEmpty) {
          throw Exception('Server gaf een lege response. Status: ${response.statusCode}');
        }
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Registratie mislukt');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('Kan geen verbinding maken met de server. Controleer je internetverbinding.');
      }
      if (e.toString().contains('FormatException')) {
        throw Exception('Server gaf ongeldige data terug. Is de backend correct gestart?');
      }
      rethrow;
    }
  }

  // Login user
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
      
      final body = {
        'email': email,
        'password': password,
      };

      final response = await http
          .post(
            url,
            headers: ApiConstants.headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        
        // Save auth data to secure storage
        await TokenStorage.saveAuthData(
          token: authResponse.token,
          userId: authResponse.userId,
          username: authResponse.username,
          email: authResponse.email,
          firstName: authResponse.firstName,
          lastName: authResponse.lastName,
          expiresAt: authResponse.expiresAt,
        );
        
        return authResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Onjuist e-mailadres of wachtwoord');
      } else {
        // Handle error responses
        if (response.body.isEmpty) {
          throw Exception('Server gaf een lege response. Status: ${response.statusCode}');
        }
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Inloggen mislukt');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('Kan geen verbinding maken met de server. Controleer je internetverbinding.');
      }
      if (e.toString().contains('FormatException')) {
        throw Exception('Server gaf ongeldige data terug. Is de backend correct gestart?');
      }
      rethrow;
    }
  }

  // Logout user
  static Future<void> logout() async {
    await TokenStorage.clearAuthData();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await TokenStorage.isLoggedIn();
  }
}
