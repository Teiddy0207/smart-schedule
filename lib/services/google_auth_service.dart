import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/auth/google_login_response.dart';
import '../utils/app_logger.dart';

/// Service for handling Google authentication
class GoogleAuthService {
  // Web Client ID for server-side token verification
  static const String _serverClientId = '467169628226-pg9m6f83rl76baqitkcbj2ch2caqmhu9.apps.googleusercontent.com';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar.readonly', // Để đọc Google Calendar
      'https://www.googleapis.com/auth/calendar.events', // Để tạo/sửa events
    ],
    serverClientId: _serverClientId, // For backend token verification
  );

  /// Get base URL based on platform
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:7070';
    } else {
      return 'http://localhost:7070';
    }
  }

  /// Sign out from Google (to allow selecting different account next time)
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      AppLogger.info('Google Sign-Out successful', tag: 'GoogleAuth');
    } catch (e) {
      AppLogger.error('Google Sign-Out error', tag: 'GoogleAuth', error: e);
      // Don't throw exception as sign out is not as critical as sign in
    }
  }

  /// Login with Google account
  static Future<GoogleLoginResponse> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Người dùng đã hủy đăng nhập Google');
      }

      // Get user info from Google account
      final googleEmail = account.email ?? '';
      final googleDisplayName = account.displayName ?? '';
      final googlePhotoUrl = account.photoUrl;
      
      AppLogger.info('Google Account Info:', tag: 'GoogleAuth');
      AppLogger.info('  Email: $googleEmail', tag: 'GoogleAuth');
      AppLogger.info('  Display Name: $googleDisplayName', tag: 'GoogleAuth');
      AppLogger.info('  Photo URL: $googlePhotoUrl', tag: 'GoogleAuth');

      // Get idToken, accessToken and refreshToken
      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken; // Google access token for Calendar API
      final serverAuthCode = auth.serverAuthCode; // Can be used to exchange for refresh token

      if (idToken == null) {
        throw Exception('Không lấy được Google ID Token');
      }

      AppLogger.info('=== Google Sign-In Debug ===', tag: 'GoogleAuth');
      AppLogger.info('idToken: ${idToken != null ? "Có" : "Không"}', tag: 'GoogleAuth');
      AppLogger.info('accessToken: ${accessToken != null ? "Có" : "Không"}', tag: 'GoogleAuth');
      AppLogger.info('serverAuthCode: ${serverAuthCode != null ? "Có" : "Không"}', tag: 'GoogleAuth');

      // Send idToken, accessToken and refreshToken (if available) to backend for verification
      final url = Uri.parse('$_baseUrl/api/v1/public/auth/google/verify');
      AppLogger.info('Calling backend: $url', tag: 'GoogleAuth');
      AppLogger.info('idToken length: ${idToken.length}', tag: 'GoogleAuth');
      
      // Prepare request body
      final requestBody = <String, dynamic>{
        'idToken': idToken,
      };
      
      // Add accessToken if available (needed for Google Calendar API)
      if (accessToken != null && accessToken.isNotEmpty) {
        requestBody['accessToken'] = accessToken;
        AppLogger.info('Sending accessToken to backend', tag: 'GoogleAuth');
      }
      
      // Add serverAuthCode if available (backend can use to exchange for refresh token)
      if (serverAuthCode != null && serverAuthCode.isNotEmpty) {
        requestBody['serverAuthCode'] = serverAuthCode;
        AppLogger.info('Sending serverAuthCode to backend', tag: 'GoogleAuth');
      }
      
      http.Response response;
      try {
        response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout. Backend không phản hồi trong 30 giây.');
          },
        );
      } on SocketException catch (e) {
        throw Exception('Không thể kết nối đến backend.\n'
            'Vui lòng kiểm tra:\n'
            '1. Backend đang chạy trên port 7070\n'
            '2. URL: $_baseUrl\n'
            '3. Lỗi: ${e.message}');
      } on http.ClientException catch (e) {
        throw Exception('Lỗi kết nối: ${e.message}\n'
            'Backend có thể đã đóng kết nối. Vui lòng kiểm tra log backend.');
      } on TimeoutException catch (e) {
        throw Exception('Request timeout. Backend không phản hồi.');
      }

      AppLogger.info('Response status: ${response.statusCode}', tag: 'GoogleAuth');
      AppLogger.debug('Response body: ${response.body}', tag: 'GoogleAuth');

      if (response.statusCode == 404) {
        throw Exception('Endpoint không tồn tại trên backend. '
            'Vui lòng kiểm tra:\n'
            '1. Backend có endpoint POST /api/v1/public/auth/google/verify không?\n'
            '2. Route đã được đăng ký trong router chưa?\n'
            '3. Backend đang chạy trên port 7070 không?');
      }

      if (response.statusCode != 200) {
        throw Exception('Đăng nhập Google thất bại. Mã lỗi: ${response.statusCode}\n'
            'Response: ${response.body}');
      }

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!doctype') || response.body.trim().startsWith('<html')) {
        throw Exception('Backend trả về HTML thay vì JSON. Có thể endpoint không đúng hoặc backend đang redirect. Vui lòng kiểm tra endpoint: $_baseUrl/api/v1/public/auth/google');
      }

      // Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Add user info from Google account to response data
      if (responseData['data'] != null) {
        (responseData['data'] as Map<String, dynamic>).addAll({
          'email': googleEmail,
          'display_name': googleDisplayName,
          'photo_url': googlePhotoUrl,
        });
      }
      
      return GoogleLoginResponse.fromJson(responseData);
    } on PlatformException catch (e) {
      // Handle errors from Google Sign-In SDK
      String errorMessage = 'Đăng nhập Google thất bại';
      
      // Log detailed error for debugging
      AppLogger.error('Google Sign-In Error:', tag: 'GoogleAuth');
      AppLogger.error('  Code: ${e.code}', tag: 'GoogleAuth');
      AppLogger.error('  Message: ${e.message}', tag: 'GoogleAuth');
      AppLogger.error('  Details: ${e.details}', tag: 'GoogleAuth');
      AppLogger.error('  Stacktrace: ${e.stacktrace}', tag: 'GoogleAuth');
      
      if (e.code == 'sign_in_failed' || e.code == 'sign_in_canceled') {
        errorMessage = 'Không thể đăng nhập Google. Vui lòng kiểm tra:\n'
            '1. Android OAuth Client ID đã được tạo với package name và SHA-1 đúng\n'
            '2. Google Sign-In API đã được bật\n'
            '3. OAuth Consent Screen đã được publish (không phải testing)\n'
            'Chi tiết lỗi: ${e.message ?? e.code}';
      } else if (e.code == 'network_error') {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      } else {
        errorMessage = 'Lỗi đăng nhập Google:\n'
            'Code: ${e.code}\n'
            'Message: ${e.message ?? "Không có thông báo"}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      // Handle other errors
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đăng nhập Google thất bại: ${e.toString()}');
    }
  }
}
