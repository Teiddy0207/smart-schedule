import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

/// Base API service for handling HTTP requests to the backend
class ApiService {
  static const String _tag = 'ApiService';
  
  /// Get base URL based on platform
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:7070';
    } else {
      return 'http://localhost:7070';
    }
  }

  /// Token for authenticated requests
  static String? _accessToken;
  
  static void setAccessToken(String? token) {
    _accessToken = token;
  }
  
  static String? get accessToken => _accessToken;

  /// Build authorization headers
  static Map<String, String> _buildHeaders({bool requireAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (requireAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }

  /// GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requireAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('GET: $url', tag: _tag);
    
    try {
      final response = await http.get(
        url,
        headers: _buildHeaders(requireAuth: requireAuth),
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('POST: $url', tag: _tag);
    
    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('PUT: $url', tag: _tag);
    
    try {
      final response = await http.put(
        url,
        headers: _buildHeaders(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('DELETE: $url', tag: _tag);
    
    try {
      final response = await http.delete(
        url,
        headers: _buildHeaders(requireAuth: requireAuth),
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    AppLogger.debug('Response status: ${response.statusCode}', tag: _tag);
    
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'status': response.statusCode, 'message': 'Success', 'data': {}};
      }
      throw Exception('Empty response with status: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    
    throw Exception(data['message'] ?? 'Request failed with status: ${response.statusCode}');
  }

  /// Handle errors
  static Map<String, dynamic> _handleError(dynamic error) {
    AppLogger.error('API Error: $error', tag: _tag);
    
    if (error is SocketException) {
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    }
    if (error is TimeoutException) {
      throw Exception('Request timeout. Server không phản hồi.');
    }
    
    throw error;
  }
}
