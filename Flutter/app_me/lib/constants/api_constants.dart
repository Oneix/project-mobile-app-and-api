class ApiConstants {
  // Base URL - Change this to your actual API URL when deploying
  // For local testing on emulator: use 10.0.2.2 (Android) or localhost (iOS/Desktop)
  static const String baseUrl = 'http://localhost:5009';
  
  // If using Android emulator, use:
  // static const String baseUrl = 'http://10.0.2.2:5009';
  
  // If using physical device on same network, use your PC's IP:
  // static const String baseUrl = 'http://192.168.x.x:5009';
  
  // API endpoints
  static const String apiPrefix = '/api';
  
  // Auth endpoints
  static const String authBase = '$apiPrefix/auth';
  static const String register = '$authBase/register';
  static const String login = '$authBase/login';
  
  // Future endpoints (for reference)
  // static const String friendsBase = '$apiPrefix/friends';
  // static const String chatsBase = '$apiPrefix/chats';
  // static const String messagesBase = '$apiPrefix/messages';
  // static const String groupsBase = '$apiPrefix/groups';
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
