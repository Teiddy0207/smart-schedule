import 'package:flutter/foundation.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  User? _currentUser;
  String? _token;
  String? _refreshToken;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get username => _currentUser?.username;

  // Login method
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create login request
      final request = LoginRequest(
        username: username,
        password: password,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // final response = await authRepository.login(request);

      // For now, simulate successful login
      if (username.isNotEmpty && password.isNotEmpty) {
        final response = LoginResponse(
          success: true,
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          user: User(
            id: '1',
            username: username,
            email: '$username@example.com',
            fullName: username,
          ),
          message: 'Đăng nhập thành công',
        );

        _isLoading = false;
        _isAuthenticated = true;
        _currentUser = response.user;
        _token = response.token;
        _refreshToken = response.refreshToken;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _isAuthenticated = false;
        _errorMessage = 'Tên đăng nhập và mật khẩu không được để trống';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _isAuthenticated = false;
      _errorMessage = 'Đã xảy ra lỗi: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Logout method
  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    _token = null;
    _refreshToken = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

