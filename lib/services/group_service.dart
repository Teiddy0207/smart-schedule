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

      // Parse response body theo format: { "status": 200, "message": "...", "data": { "items": [...] } }
      final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
      print('Response structure: status=${decodedBody['status']}, message=${decodedBody['message']}');
      
      // Lấy danh sách groups từ data.items
      if (!decodedBody.containsKey('data') || decodedBody['data'] == null) {
        print('⚠ Response không có field "data"');
        return [];
      }
      
      final data = decodedBody['data'] as Map<String, dynamic>;
      if (!data.containsKey('items') || data['items'] == null) {
        print('⚠ Response data không có field "items"');
        return [];
      }
      
      final groupsList = data['items'] as List<dynamic>;
      print('Found ${groupsList.length} groups in response');
      
      // Parse từng group (mỗi item là group object trực tiếp)
      final groups = <Group>[];
      for (int i = 0; i < groupsList.length; i++) {
        final item = groupsList[i];
        
        try {
          if (item is Map<String, dynamic>) {
            // Item chính là group object với các field: id, name, description, created_at, updated_at
            final group = Group.fromJson(item);
            groups.add(group);
            print('  ✅ Parsed group $i: ${group.name} (ID: ${group.id})');
          } else {
            print('  ⚠ Item $i is not a Map: ${item.runtimeType}');
          }
        } catch (e, stackTrace) {
          print('  ❌ Error parsing item $i: $e');
          print('  Stack trace: $stackTrace');
          // Tiếp tục với item tiếp theo thay vì throw
        }
      }
      
      print('✅ Successfully parsed ${groups.length} groups from ${groupsList.length} items');
      return groups;
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

  /// Thêm users vào nhóm
  /// POST /api/v1/private/products/groups/users
  /// Body: { "group_id": "...", "user_ids": ["...", "..."] }
  static Future<void> addUsersToGroup({
    required AuthProvider authProvider,
    required String groupId,
    required List<String> userIds,
  }) async {
    try {
      final appToken = authProvider.token;
      if (appToken == null || appToken.isEmpty) {
        throw Exception('Chưa đăng nhập. Vui lòng đăng nhập trước.');
      }

      final url = Uri.parse('$_baseUrl/api/v1/private/products/groups/users');

      print('=== Add Users To Group API ===');
      print('URL: $url');
      print('Group ID: $groupId');
      print('User IDs: $userIds');

      final requestBody = {
        'group_id': groupId,
        'user_ids': userIds,
      };

      print('=== Add Users To Group API ===');
      print('Request body: ${jsonEncode(requestBody)}');
      print('User IDs being sent: $userIds');
      print('Note: Backend will convert users.id to social_logins.id if needed');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $appToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
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
        throw Exception('Nhóm hoặc user không tồn tại.');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorBody?['message'] ?? errorBody?['error'] ?? 'Lỗi không xác định';
        throw Exception('Lỗi khi thêm users vào nhóm: $errorMessage');
      }

      print('✅ Users added to group successfully');
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
      throw Exception('Lỗi khi thêm user vào nhóm: ${e.toString()}');
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
      
      // Log chi tiết để debug
      print('=== Get Users By Group ID Response Debug ===');
      print('Data keys: ${data.keys.toList()}');
      if (data.containsKey('users') && data['users'] is List) {
        final users = data['users'] as List<dynamic>;
        print('Users count: ${users.length}');
        for (int i = 0; i < users.length; i++) {
          final user = users[i];
          if (user is Map<String, dynamic>) {
            print('User $i keys: ${user.keys.toList()}');
            if (user.containsKey('user') && user['user'] is Map<String, dynamic>) {
              final userData = user['user'] as Map<String, dynamic>;
              print('  User data keys: ${userData.keys.toList()}');
              print('  User data: $userData');
              print('  provider_name: ${userData['provider_name']} (type: ${userData['provider_name']?.runtimeType})');
              print('  provider_email: ${userData['provider_email']} (type: ${userData['provider_email']?.runtimeType})');
            }
          }
        }
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

