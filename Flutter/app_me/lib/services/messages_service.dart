import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_models.dart';
import '../utils/token_storage.dart';

class MessagesService {
  static const String baseUrl = 'http://localhost:5009/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all conversations (users with message history)
  static Future<List<ChatConversationModel>> getConversations() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: headers,
      );

      print('Get conversations - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatConversationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load conversations (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Error getting conversations: $e');
      rethrow;
    }
  }

  // Get message history with a user
  static Future<List<MessageModel>> getMessageHistory(int userId, {int? beforeId}) async {
    try {
      final headers = await _getHeaders();
      var url = '$baseUrl/messages/history/$userId';
      if (beforeId != null) {
        url += '?beforeId=$beforeId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load message history: ${response.body}');
      }
    } catch (e) {
      print('Error getting message history: $e');
      rethrow;
    }
  }

  // Send a message
  static Future<MessageModel> sendMessage(SendMessageRequest request) async {
    try {
      final headers = await _getHeaders();
      print('Sending message to: ${request.receiverId}');
      print('Message content: ${request.content}');
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return MessageModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to send message (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Edit a message
  static Future<MessageModel> editMessage(int messageId, EditMessageRequest request) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/messages/$messageId'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return MessageModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to edit message: ${response.body}');
      }
    } catch (e) {
      print('Error editing message: $e');
      rethrow;
    }
  }

  // Delete a message
  static Future<void> deleteMessage(int messageId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/messages/$messageId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete message: ${response.body}');
      }
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(int senderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/messages/mark-read/$senderId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        print('Mark as read failed - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to mark messages as read (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Error marking messages as read: $e');
      // Don't rethrow - marking as read shouldn't break the app
    }
  }
}
