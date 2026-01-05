class Group {
  final String id;
  final String name;
  final String description;

  Group({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class GroupUser {
  final String id;
  final String userId;
  final User user;
  final String groupId;
  final Group group;
  final DateTime createdAt;

  GroupUser({
    required this.id,
    required this.userId,
    required this.user,
    required this.groupId,
    required this.group,
    required this.createdAt,
  });

  factory GroupUser.fromJson(Map<String, dynamic> json) {
    print('🔍 GroupUser.fromJson - Parsing group user:');
    print('  JSON keys: ${json.keys.toList()}');
    
    // Parse user với null safety
    if (!json.containsKey('user') || json['user'] == null) {
      throw Exception('GroupUser.fromJson: Field "user" không được null. JSON: $json');
    }
    
    if (json['user'] is! Map<String, dynamic>) {
      throw Exception('GroupUser.fromJson: Field "user" phải là Map<String, dynamic>. Nhận được: ${json['user'].runtimeType}');
    }
    
    final userJson = json['user'] as Map<String, dynamic>;
    print('  User JSON before parsing: $userJson');
    
    final user = User.fromJson(userJson);
    print('  ✅ Parsed User: id=${user.id}, name="${user.providerName}", email="${user.providerEmail}"');
    
    // Parse group với null safety
    Group? group;
    if (json.containsKey('group') && json['group'] != null && json['group'] is Map<String, dynamic>) {
      group = Group.fromJson(json['group'] as Map<String, dynamic>);
    } else {
      // Nếu không có group, tạo một group object từ group_id
      print('  ⚠ Group field missing or null, creating from group_id');
      group = Group(
        id: json['group_id']?.toString() ?? '',
        name: '',
        description: '',
      );
    }
    
    return GroupUser(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      user: user,
      groupId: json['group_id']?.toString() ?? '',
      group: group,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}

class User {
  final String id;
  final String providerName;
  final String providerEmail;

  User({
    required this.id,
    required this.providerName,
    required this.providerEmail,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Debug: Log toàn bộ json để xem structure
    print('🔍 User.fromJson - Parsing user data:');
    print('  JSON keys: ${json.keys.toList()}');
    print('  Full JSON: $json');
    
    // Helper function để lấy giá trị string từ JSON, xử lý null
    String? getStringValue(Map<String, dynamic> json, String key) {
      if (!json.containsKey(key)) {
        print('    ⚠ Key "$key" not found');
        return null;
      }
      final value = json[key];
      print('    Key "$key" value: $value (type: ${value?.runtimeType})');
      
      if (value == null) {
        print('    ⚠ Value is null');
        return null;
      }
      
      final str = value.toString().trim();
      if (str.isEmpty) {
        print('    ⚠ Value is empty string');
        return null;
      }
      if (str == 'null' || str == 'Null' || str == 'NULL') {
        print('    ⚠ Value is string "null"');
        return null;
      }
      
      print('    ✅ Valid value: $str');
      return str;
    }
    
    // Thử các field names có thể có cho name
    String name = '';
    name = getStringValue(json, 'provider_name') ?? 
           getStringValue(json, 'name') ?? 
           getStringValue(json, 'username') ?? 
           getStringValue(json, 'full_name') ?? 
           getStringValue(json, 'display_name') ?? 
           '';
    
    if (name.isNotEmpty) {
      print('  ✅ Final name: "$name"');
    } else {
      print('  ❌ No name found - all values are null/empty');
    }
    
    // Thử các field names có thể có cho email
    String email = '';
    email = getStringValue(json, 'provider_email') ?? 
            getStringValue(json, 'email') ?? 
            '';
    
    if (email.isNotEmpty) {
      print('  ✅ Final email: "$email"');
    } else {
      print('  ❌ No email found - all values are null/empty');
    }
    
    final user = User(
      id: json['id']?.toString() ?? '',
      providerName: name,
      providerEmail: email,
    );
    
    print('  📝 Final Parsed User: id=${user.id}, name="$name", email="$email"');
    print('  📝 User object: providerName="${user.providerName}", providerEmail="${user.providerEmail}"');
    
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_name': providerName,
      'provider_email': providerEmail,
    };
  }
}

class CreateGroupRequest {
  final String name;
  final String description;

  CreateGroupRequest({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

class CreateGroupResponse {
  final Group group;

  CreateGroupResponse({
    required this.group,
  });

  factory CreateGroupResponse.fromJson(Map<String, dynamic> json) {
    if (json['group'] == null) {
      throw Exception('Response không chứa thông tin nhóm (group is null)');
    }
    
    final groupData = json['group'];
    if (groupData is! Map<String, dynamic>) {
      throw Exception('Thông tin nhóm không đúng định dạng. Nhận được: ${groupData.runtimeType}');
    }
    
    return CreateGroupResponse(
      group: Group.fromJson(groupData),
    );
  }
}

class GetUsersByGroupIdResponse {
  final String groupId;
  final Group group;
  final List<GroupUser> users;

  GetUsersByGroupIdResponse({
    required this.groupId,
    required this.group,
    required this.users,
  });

  factory GetUsersByGroupIdResponse.fromJson(Map<String, dynamic> json) {
    // Xử lý group_id
    final groupId = json['group_id']?.toString() ?? '';
    if (groupId.isEmpty) {
      throw Exception('group_id không được để trống');
    }
    
    // Xử lý group
    if (json['group'] == null) {
      throw Exception('Field "group" không được null');
    }
    
    if (json['group'] is! Map<String, dynamic>) {
      throw Exception('Field "group" phải là Map<String, dynamic>. Nhận được: ${json['group'].runtimeType}');
    }
    
    // Xử lý users - có thể null hoặc empty
    List<GroupUser> users = [];
    if (json['users'] != null) {
      if (json['users'] is List) {
        final usersList = json['users'] as List<dynamic>;
        print('📋 GetUsersByGroupIdResponse.fromJson - Parsing ${usersList.length} users...');
        
        for (int i = 0; i < usersList.length; i++) {
          final userItem = usersList[i];
          if (userItem == null) {
            print('  ⚠ User item $i is null, skipping');
            continue;
          }
          
          if (userItem is! Map<String, dynamic>) {
            print('  ⚠ User item $i is not Map, type: ${userItem.runtimeType}, skipping');
            continue;
          }
          
          try {
            final groupUser = GroupUser.fromJson(userItem);
            users.add(groupUser);
            print('  ✅ Successfully parsed user $i: ${groupUser.user.id}');
          } catch (e) {
            print('  ❌ Error parsing user $i: $e');
            print('  User item data: $userItem');
            // Không throw, chỉ skip user này để không làm crash toàn bộ
            continue;
          }
        }
        
        print('📋 Total users parsed successfully: ${users.length}/${usersList.length}');
      } else {
        throw Exception('Field "users" phải là List. Nhận được: ${json['users'].runtimeType}');
      }
    } else {
      print('⚠ GetUsersByGroupIdResponse.fromJson - Field "users" is null or missing, using empty list');
    }
    
    return GetUsersByGroupIdResponse(
      groupId: groupId,
      group: Group.fromJson(json['group'] as Map<String, dynamic>),
      users: users,
    );
  }
}

