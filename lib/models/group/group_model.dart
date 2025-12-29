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
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
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
    return CreateGroupResponse(
      group: Group.fromJson(json['group'] as Map<String, dynamic>),
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
    return GetUsersByGroupIdResponse(
      groupId: json['group_id'] as String,
      group: Group.fromJson(json['group'] as Map<String, dynamic>),
      users: (json['users'] as List<dynamic>)
          .map((e) => GroupUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

