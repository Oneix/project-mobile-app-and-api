import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/token_storage.dart';

class UserProfile {
  final int userId;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime createdAt;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    required this.isOnline,
    this.lastSeenAt,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      isOnline: json['isOnline'] as bool,
      lastSeenAt: json['lastSeenAt'] != null 
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }
}

class UserService {
  // Get current user profile
  static Future<UserProfile> getProfile() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfile}');
      
      final response = await http
          .get(
            url,
            headers: ApiConstants.headersWithAuth(token),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('authenticatie verlopen, log opnieuw in');
      } else {
        throw Exception('kon profiel niet ophalen');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('kan geen verbinding maken met de server');
      }
      rethrow;
    }
  }

  // Update user profile
  static Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
  }) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfile}');
      
      final body = <String, dynamic>{};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (profilePictureUrl != null) body['profilePictureUrl'] = profilePictureUrl;

      final response = await http
          .put(
            url,
            headers: ApiConstants.headersWithAuth(token),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = UserProfile.fromJson(data);
        
        // Update stored user data
        await TokenStorage.saveAuthData(
          token: token,
          userId: profile.userId,
          username: profile.username,
          email: profile.email,
          firstName: profile.firstName,
          lastName: profile.lastName,
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );
        
        return profile;
      } else if (response.statusCode == 401) {
        throw Exception('authenticatie verlopen, log opnieuw in');
      } else {
        throw Exception('kon profiel niet bijwerken');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('kan geen verbinding maken met de server');
      }
      rethrow;
    }
  }
}
