import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';
import '../models/group_models.dart';

class GroupsService {
  static const String baseUrl = 'http://localhost:5009/api/groups';

  static Future<List<GroupModel>> getMyGroups() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load groups: ${response.body}');
    }
  }

  static Future<GroupModel> getGroupDetails(int groupId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$baseUrl/$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return GroupModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load group: ${response.body}');
    }
  }

  static Future<GroupModel> createGroup(CreateGroupRequest request) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return GroupModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create group: ${response.body}');
    }
  }

  static Future<List<GroupMessageModel>> getGroupMessages(
    int groupId, {
    int? beforeId,
    int limit = 50,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (beforeId != null) 'beforeId': beforeId.toString(),
    };

    final uri = Uri.parse(
      '$baseUrl/$groupId/messages',
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GroupMessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.body}');
    }
  }

  static Future<GroupMessageModel> sendGroupMessage(
    int groupId,
    SendGroupMessageRequest request,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/$groupId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return GroupMessageModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  static Future<GroupMemberModel> addMember(int groupId, int userId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/$groupId/members'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return GroupMemberModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add member: ${response.body}');
    }
  }

  static Future<void> removeMember(int groupId, int userId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/$groupId/members/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove member: ${response.body}');
    }
  }

  static Future<GroupModel> updateGroup(
    int groupId, {
    String? name,
    String? description,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.put(
      Uri.parse('$baseUrl/$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return GroupModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update group: ${response.body}');
    }
  }

  static Future<void> deleteGroup(int groupId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete group: ${response.body}');
    }
  }

  static Future<GroupMessageModel> editGroupMessage(
    int groupId,
    int messageId,
    String content,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.put(
      Uri.parse('$baseUrl/$groupId/messages/$messageId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 200) {
      return GroupMessageModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to edit message: ${response.body}');
    }
  }

  static Future<void> deleteGroupMessage(int groupId, int messageId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/$groupId/messages/$messageId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message: ${response.body}');
    }
  }
}
