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

      // Parse response body
      dynamic decodedBody;
      try {
        decodedBody = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Không thể parse response JSON: ${e.toString()}');
      }

      if (decodedBody is! Map<String, dynamic>) {
        throw Exception('Response không phải là object. Nhận được: ${decodedBody.runtimeType}');
      }

      final responseData = decodedBody;
      
      // Xử lý response có thể có 'data' hoặc không
      Map<String, dynamic> data;
      if (responseData.containsKey('data') && responseData['data'] != null) {
        if (responseData['data'] is! Map<String, dynamic>) {
          throw Exception('Field "data" không phải là object. Nhận được: ${responseData['data'].runtimeType}');
        }
        data = responseData['data'] as Map<String, dynamic>;
        print('Using data from responseData[\'data\']');
      } else {
        // Nếu không có 'data', thử dùng trực tiếp responseData
        data = responseData;
        print('Using responseData directly (no data wrapper)');
      }
      
      print('Data keys: ${data.keys.toList()}');
      
      // Xử lý response: có thể có 'group', 'id', hoặc không có gì
      Map<String, dynamic>? groupData;
      
      // Trường hợp 1: Có 'group' object
      if (data.containsKey('group') && data['group'] != null) {
        if (data['group'] is! Map<String, dynamic>) {
          throw Exception('Field "group" không phải là object. Nhận được: ${data['group'].runtimeType}');
        }
        groupData = data['group'] as Map<String, dynamic>;
      }
      // Trường hợp 2: Có 'id' trực tiếp trong response (backend trả về id của nhóm vừa tạo)
      else if (data.containsKey('id') && data['id'] != null) {
        // Tạo group object từ id và name/description đã gửi
        groupData = {
          'id': data['id'].toString(),
          'name': name, // Dùng name từ request
          'description': description, // Dùng description từ request
        };
      }
      // Trường hợp 3: Response chỉ có status và message (nhóm đã tạo nhưng không trả về thông tin)
      else {
        // Backend đã tạo nhóm thành công nhưng không trả về thông tin
        // Trả về group với ID rỗng để frontend xử lý (pop về màn hình trước)
        return CreateGroupResponse(
          group: Group(
            id: '', // Không có ID
            name: name,
            description: description,
          ),
        );
      }
      
      return CreateGroupResponse.fromJson({'group': groupData});
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

  /// Lấy danh sách tất cả nhóm của user hiện tại
  /// GET /api/v1/private/products/groups
  static Future<List<Group>> getMyGroups({
    required AuthProvider authProvider,
  }) async {
    try {
      final appToken = authProvider.token;
      if (appToken == null || appToken.isEmpty) {
        throw Exception('Chưa đăng nhập. Vui lòng đăng nhập trước.');
      }

      final url = Uri.parse('$_baseUrl/api/v1/private/products/groups');

      print('=== Get My Groups API ===');
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

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorBody?['message'] ?? errorBody?['error'] ?? 'Lỗi không xác định';
        throw Exception('Lỗi khi lấy danh sách nhóm: $errorMessage');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Xử lý response có thể có 'data' hoặc không
      List<dynamic> groupsList;
      if (responseData.containsKey('data') && responseData['data'] != null) {
        if (responseData['data'] is List) {
          groupsList = responseData['data'] as List<dynamic>;
        } else if (responseData['data'] is Map && (responseData['data'] as Map).containsKey('items')) {
          groupsList = (responseData['data'] as Map<String, dynamic>)['items'] as List<dynamic>;
        } else {
          groupsList = [];
        }
      } else if (responseData.containsKey('items')) {
        groupsList = responseData['items'] as List<dynamic>;
      } else if (responseData is List) {
        groupsList = responseData as List<dynamic>;
      } else {
        groupsList = [];
      }

      return groupsList
          .map((item) {
            if (item is Map<String, dynamic>) {
              // Nếu item có 'group' field, dùng nó
              if (item.containsKey('group') && item['group'] is Map<String, dynamic>) {
                return Group.fromJson(item['group'] as Map<String, dynamic>);
              }
              // Nếu không, dùng trực tiếp item
              return Group.fromJson(item);
            }
            return null;
          })
          .whereType<Group>()
          .toList();
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
      throw Exception('Lỗi khi lấy danh sách nhóm: ${e.toString()}');
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
      
      // Xử lý response có thể có 'data' hoặc không
      Map<String, dynamic> data;
      if (responseData.containsKey('data') && responseData['data'] != null) {
        if (responseData['data'] is! Map<String, dynamic>) {
          throw Exception('Field "data" không phải là object. Nhận được: ${responseData['data'].runtimeType}');
        }
        data = responseData['data'] as Map<String, dynamic>;
      } else {
        // Nếu không có 'data', thử dùng trực tiếp responseData
        data = responseData;
      }
      
      // Kiểm tra các field bắt buộc
      if (!data.containsKey('group_id') || data['group_id'] == null) {
        throw Exception('Response không chứa group_id. Cấu trúc: ${response.body}');
      }
      
      // Nếu không có 'group' trong response, tạo một group object từ group_id
      if (!data.containsKey('group') || data['group'] == null) {
        print('⚠ Response không có field "group", tạo group object từ group_id');
        data['group'] = {
          'id': data['group_id'].toString(),
          'name': '', // Sẽ được set sau nếu có
          'description': '',
        };
      }
      
      if (data['group'] is! Map<String, dynamic>) {
        throw Exception('Field "group" không phải là object. Nhận được: ${data['group'].runtimeType}');
      }
      
      // users có thể là null hoặc empty list
      if (!data.containsKey('users')) {
        data['users'] = [];
      }
      
      if (data['users'] != null && data['users'] is! List) {
        throw Exception('Field "users" không phải là list. Nhận được: ${data['users'].runtimeType}');
      }
      
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

