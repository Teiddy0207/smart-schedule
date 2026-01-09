class LoginRequest {
  final String identifiers; // phone, username, or email
  final String password;

  LoginRequest({
    required this.identifiers,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifiers': identifiers,
      'password': password,
    };
  }
}


