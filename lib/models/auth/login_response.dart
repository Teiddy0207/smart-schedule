/// Standard API response wrapper
class ApiResponse<T> {
  final int status;
  final String message;
  final T data;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      status: json['status'] ?? 200,
      message: json['message'] ?? '',
      data: fromJsonT(json['data'] ?? {}),
    );
  }
}

/// Login response from Backend
/// GET: POST /api/v1/public/auth/login
class LoginResponse {
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}

/// User data model
class User {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final String? fullName;
  final String? avatar;
  final bool isActive;
  final Map<String, dynamic>? additionalInfo;

  User({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.fullName,
    this.avatar,
    this.isActive = true,
    this.additionalInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? json['email']?.toString() ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String? ?? json['display_name'] as String?,
      avatar: json['avatar'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      additionalInfo: json['additional_info'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar': avatar,
      'is_active': isActive,
      'additional_info': additionalInfo,
    };
  }
}
