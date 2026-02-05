class ApiConstants {

  static const String baseUrl = 'http://localhost:5009';
  
  
  // API endpoints
  static const String apiPrefix = '/api';
  
  // Auth endpoints
  static const String authBase = '$apiPrefix/auth';
  static const String register = '$authBase/register';
  static const String login = '$authBase/login';
  
  // User endpoints
  static const String userBase = '$apiPrefix/user';
  static const String userProfile = '$userBase/profile';
  
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
