class GoogleLoginResponse {
  final int status;
  final String message;
  final GoogleTokenData data;

  GoogleLoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GoogleLoginResponse.fromJson(Map<String, dynamic> json) {
    return GoogleLoginResponse(
      status: json['status'],
      message: json['message'],
      data: GoogleTokenData.fromJson(json['data']),
    );
  }
}

class GoogleTokenData {
  final String accessToken;
  final String refreshToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  GoogleTokenData({
    required this.accessToken,
    required this.refreshToken,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory GoogleTokenData.fromJson(Map<String, dynamic> json) {
    return GoogleTokenData(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      email: json['email'],
      displayName: json['display_name'],
      photoUrl: json['photo_url'],
    );
  }
}
