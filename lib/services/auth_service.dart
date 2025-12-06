import '../core/api_client.dart';
import '../config/api_config.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      ApiConfig.loginEndpoint,
      data: request.toJson(),
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiConfig.forgotPasswordEndpoint,
      data: {'email': email},
    );
  }
}

