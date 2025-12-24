import 'package:flutter/foundation.dart';
import '../models/auth/login_response.dart';
import '../services/google_auth_service.dart';

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
  Future<void> logout() async {
    // Sign out khỏi Google để lần sau có thể chọn tài khoản khác
    await GoogleAuthService.signOut();
    
    _isAuthenticated = false;
    _currentUser = null;
    _token = null;
    _refreshToken = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Google login method
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final googleResponse = await GoogleAuthService.loginWithGoogle();

      // Convert GoogleLoginResponse to LoginResponse format
      _isLoading = false;
      _isAuthenticated = true;
      _token = googleResponse.data.accessToken;
      _refreshToken = googleResponse.data.refreshToken;
      
      // Lấy thông tin user từ Google account (đã được thêm vào response)
      // TODO: Có thể gọi API để lấy thông tin từ bảng social_logins (provider_username, provider_user_email)
      _currentUser = User(
        id: 'google_user_${googleResponse.data.email ?? ''}',
        username: googleResponse.data.displayName ?? googleResponse.data.email ?? 'google_user',
        email: googleResponse.data.email,
        fullName: googleResponse.data.displayName,
      );
      
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _isAuthenticated = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

