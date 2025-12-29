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
    return GroupUser(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      groupId: json['group_id'] as String,
      group: Group.fromJson(json['group'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
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
    return User(
      id: json['id'] as String,
      providerName: json['provider_name'] as String? ?? '',
      providerEmail: json['provider_email'] as String? ?? '',
    );
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
        users = (json['users'] as List<dynamic>)
            .where((e) => e != null && e is Map<String, dynamic>)
            .map((e) => GroupUser.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Field "users" phải là List. Nhận được: ${json['users'].runtimeType}');
      }
    }
    
    return GetUsersByGroupIdResponse(
      groupId: groupId,
      group: Group.fromJson(json['group'] as Map<String, dynamic>),
      users: users,
    );
  }
}

