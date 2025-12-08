class LoginResponse {
  final String? token;
  final String? refreshToken;
  final User? user;
  final String? message;
  final bool success;

  LoginResponse({
    this.token,
    this.refreshToken,
    this.user,
    this.message,
    this.success = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
      'message': message,
      'success': success,
    };
  }
}

class User {
  final String id;
  final String username;
  final String? email;
  final String? fullName;
  final String? avatar;
  final Map<String, dynamic>? additionalInfo;

  User({
    required this.id,
    required this.username,
    this.email,
    this.fullName,
    this.avatar,
    this.additionalInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      avatar: json['avatar'] as String?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'additionalInfo': additionalInfo,
    };
  }
}

