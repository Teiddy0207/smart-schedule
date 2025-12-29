import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/group/group_model.dart';
import '../providers/auth_provider.dart';

class GroupService {
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:7070';
    } else {
      return 'http://localhost:7070';
    }
  }

  /// Tạo nhóm mới
  /// POST /api/v1/private/products/groups
  static Future<CreateGroupResponse> createGroup({
    required AuthProvider authProvider,
    required String name,
    required String description,
  }) async {
    try {
      final appToken = authProvider.token;
      if (appToken == null || appToken.isEmpty) {
        throw Exception('Chưa đăng nhập. Vui lòng đăng nhập trước.');
      }

      final url = Uri.parse('$_baseUrl/api/v1/private/products/groups');
      
      final requestBody = CreateGroupRequest(
        name: name,
        description: description,
      );

      print('=== Create Group API ===');
      print('URL: $url');
      print('Body: ${jsonEncode(requestBody.toJson())}');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $appToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Backend không phản hồi trong 30 giây.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Token đã hết hạn. Vui lòng đăng nhập lại.');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorBody?['message'] ?? errorBody?['error'] ?? 'Lỗi không xác định';
        throw Exception('Lỗi khi tạo nhóm: $errorMessage');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;
      
      return CreateGroupResponse.fromJson(data);
    } on http.ClientException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    } on SocketException catch (e) {
      throw Exception('Không thể kết nối đến backend.\n'
          'Vui lòng kiểm tra:\n'
          '1. Backend đang chạy trên port 7070\n'
          '2. URL: $_baseUrl\n'
          '3. Lỗi: ${e.message}');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Lỗi khi tạo nhóm: ${e.toString()}');
    }
  }

  /// Lấy danh sách users trong nhóm
  /// GET /api/v1/private/products/groups/{groupId}/users
  static Future<GetUsersByGroupIdResponse> getUsersByGroupId({
    required AuthProvider authProvider,
    required String groupId,
  }) async {
    try {
      final appToken = authProvider.token;
      if (appToken == null || appToken.isEmpty) {
        throw Exception('Chưa đăng nhập. Vui lòng đăng nhập trước.');
      }

      final url = Uri.parse('$_baseUrl/api/v1/private/products/groups/$groupId/users');

      print('=== Get Users By Group ID API ===');
      print('URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $appToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Backend không phản hồi trong 30 giây.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Token đã hết hạn. Vui lòng đăng nhập lại.');
      }

      if (response.statusCode == 404) {
        throw Exception('Nhóm không tồn tại.');
      }

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorBody?['message'] ?? errorBody?['error'] ?? 'Lỗi không xác định';
        throw Exception('Lỗi khi lấy danh sách users: $errorMessage');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;
      
      return GetUsersByGroupIdResponse.fromJson(data);
    } on http.ClientException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    } on SocketException catch (e) {
      throw Exception('Không thể kết nối đến backend.\n'
          'Vui lòng kiểm tra:\n'
          '1. Backend đang chạy trên port 7070\n'
          '2. URL: $_baseUrl\n'
          '3. Lỗi: ${e.message}');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Lỗi khi lấy danh sách users: ${e.toString()}');
    }
  }
}

