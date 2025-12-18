import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/auth/google_login_response.dart';

class GoogleAuthService {
  // Web Client ID for server-side token verification
  static const String _serverClientId = '467169628226-pg9m6f83rl76baqitkcbj2ch2caqmhu9.apps.googleusercontent.com';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar.readonly', // Để đọc Google Calendar
    ],
    serverClientId: _serverClientId, // For backend token verification
  );

  // Get base URL based on platform
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:7070';
    } else {
      return 'http://localhost:7070';
    }
  }

  // Sign out khỏi Google (để cho phép chọn tài khoản khác lần sau)
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('Google Sign-Out successful');
    } catch (e) {
      print('Google Sign-Out error: $e');
      // Không throw exception vì sign out không quan trọng bằng sign in
    }
  }

  static Future<GoogleLoginResponse> loginWithGoogle() async {
    try {
    
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Người dùng đã hủy đăng nhập Google');
      }

      // Lấy thông tin user từ Google account
      final googleEmail = account.email ?? '';
      final googleDisplayName = account.displayName ?? '';
      final googlePhotoUrl = account.photoUrl;
      
      print('Google Account Info:');
      print('  Email: $googleEmail');
      print('  Display Name: $googleDisplayName');
      print('  Photo URL: $googlePhotoUrl');

      // 2. Lấy idToken, accessToken và refreshToken
      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken; // Google access token để gọi Calendar API
      final serverAuthCode = auth.serverAuthCode; // Có thể dùng để exchange lấy refresh token

      if (idToken == null) {
        throw Exception('Không lấy được Google ID Token');
      }

      print('=== Google Sign-In Debug ===');
      print('idToken: ${idToken != null ? "Có" : "Không"}');
      print('accessToken: ${accessToken != null ? "Có" : "Không"}');
      print('serverAuthCode: ${serverAuthCode != null ? "Có" : "Không"}');

    // 3. Gửi idToken, accessToken và refreshToken (nếu có) lên backend để verify
    final url = Uri.parse('$_baseUrl/api/v1/public/auth/google/verify');
    print('Calling backend: $url');
    print('idToken length: ${idToken.length}');
    
    // Chuẩn bị request body
    final requestBody = <String, dynamic>{
      'idToken': idToken,
    };
    
    // Thêm accessToken nếu có (cần để gọi Google Calendar API)
    if (accessToken != null && accessToken.isNotEmpty) {
      requestBody['accessToken'] = accessToken;
      print('Sending accessToken to backend');
    }
    
    // Thêm serverAuthCode nếu có (backend có thể dùng để exchange lấy refresh token)
    if (serverAuthCode != null && serverAuthCode.isNotEmpty) {
      requestBody['serverAuthCode'] = serverAuthCode;
      print('Sending serverAuthCode to backend');
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

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

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

    // Kiểm tra xem response có phải HTML không
    if (response.body.trim().startsWith('<!doctype') || response.body.trim().startsWith('<html')) {
      throw Exception('Backend trả về HTML thay vì JSON. Có thể endpoint không đúng hoặc backend đang redirect. Vui lòng kiểm tra endpoint: $_baseUrl/api/v1/public/auth/google');
    }

      // 4. Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Thêm thông tin user từ Google account vào response data
      if (responseData['data'] != null) {
        (responseData['data'] as Map<String, dynamic>).addAll({
          'email': googleEmail,
          'display_name': googleDisplayName,
          'photo_url': googlePhotoUrl,
        });
      }
      
      return GoogleLoginResponse.fromJson(responseData);
    } on PlatformException catch (e) {
      // Xử lý lỗi từ Google Sign-In SDK
      String errorMessage = 'Đăng nhập Google thất bại';
      
      // Log chi tiết lỗi để debug
      print('Google Sign-In Error:');
      print('  Code: ${e.code}');
      print('  Message: ${e.message}');
      print('  Details: ${e.details}');
      print('  Stacktrace: ${e.stacktrace}');
      
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
      // Xử lý các lỗi khác
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đăng nhập Google thất bại: ${e.toString()}');
    }
  }
}
