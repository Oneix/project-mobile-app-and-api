import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/token_storage.dart';

class UploadService {
  static Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('geen authenticatie token gevonden');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/upload/profile-picture');
      
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fileUrl = data['url'] as String;
        
        // Return full URL
        return '${ApiConstants.baseUrl}$fileUrl';
      } else if (response.statusCode == 401) {
        throw Exception('sessie verlopen. log opnieuw in');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'uploaden mislukt');
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
