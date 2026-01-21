import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/token_storage.dart';
import '../models/friend_models.dart';

class FriendsService {
  // Send friend request
  static Future<FriendRequestModel> sendFriendRequest(String username) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/friends/request');
      
      final response = await http
          .post(
            url,
            headers: ApiConstants.headersWithAuth(token),
            body: jsonEncode({'username': username}),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FriendRequestModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('sessie verlopen, log opnieuw in');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'vriendschapsverzoek verzenden mislukt');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('kan geen verbinding maken met de server');
      }
      rethrow;
    }
  }

  // Get pending friend requests
  static Future<List<FriendRequestModel>> getPendingRequests() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/friends/requests/pending');
      
      final response = await http
          .get(
            url,
            headers: ApiConstants.headersWithAuth(token),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FriendRequestModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('sessie verlopen, log opnieuw in');
      } else {
        throw Exception('kon verzoeken niet ophalen');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('kan geen verbinding maken met de server');
      }
      rethrow;
    }
  }

  // Accept friend request
  static Future<void> acceptFriendRequest(int requestId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/friends/request/$requestId/accept');
      
      final response = await http
          .post(
            url,
            headers: ApiConstants.headersWithAuth(token),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('sessie verlopen, log opnieuw in');
        }
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'accepteren mislukt');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('kan geen verbinding maken met de server');
      }
      rethrow;
    }
  }

  // Reject friend request
  static Future<void> rejectFriendRequest(int requestId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/friends/request/$requestId/reject');
      
      final response = await http
          .post(
            url,
            headers: ApiConstants.headersWithAuth(token),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('sessie verlopen, log opnieuw in');
        }
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'afwijzen mislukt');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('kan geen verbinding maken met de server');
      }
      rethrow;
    }
  }

  // Get friends list
  static Future<List<FriendModel>> getFriends() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/friends');
      
      final response = await http
          .get(
            url,
            headers: ApiConstants.headersWithAuth(token),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FriendModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('sessie verlopen, log opnieuw in');
      } else {
        throw Exception('kon vrienden niet ophalen');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('kan geen verbinding maken met de server');
      }
      rethrow;
    }
  }

  // Unfriend a user
  static Future<void> unfriend(int friendshipId) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/friends/$friendshipId');
      
      final response = await http
          .delete(
            url,
            headers: ApiConstants.headersWithAuth(token),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('sessie verlopen, log opnieuw in');
        }
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'verwijderen mislukt');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('kan geen verbinding maken met de server');
      }
      rethrow;
    }
  }

  // Search users
  static Future<List<UserSearchResult>> searchUsers(String query) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/friends/search?query=${Uri.encodeComponent(query)}');
      
      final response = await http
          .get(
            url,
            headers: ApiConstants.headersWithAuth(token),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserSearchResult.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('sessie verlopen, log opnieuw in');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'zoeken mislukt');
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
