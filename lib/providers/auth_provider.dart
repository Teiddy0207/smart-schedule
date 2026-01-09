import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/login_response.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  User? _currentUser;
  String? _token;
  String? _refreshToken;

  // Keys cho SharedPreferences
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUsername = 'auth_username';
  static const String _keyEmail = 'auth_email';
  static const String _keyFullName = 'auth_full_name';

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get username => _currentUser?.username;

  // Constructor - Load token từ SharedPreferences khi khởi tạo
  AuthProvider() {
    _loadTokenFromStorage();
  }

  // Load token từ SharedPreferences
  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyToken);
      final refreshToken = prefs.getString(_keyRefreshToken);
      final userId = prefs.getString(_keyUserId);
      final username = prefs.getString(_keyUsername);
      final email = prefs.getString(_keyEmail);
      final fullName = prefs.getString(_keyFullName);

      if (token != null && token.isNotEmpty) {
        _token = token;
        _refreshToken = refreshToken;
        _isAuthenticated = true;
        
        // Set token for API calls
        ApiService.setAccessToken(token);
        
        if (userId != null && username != null) {
          _currentUser = User(
            id: userId,
            username: username,
            email: email,
            fullName: fullName,
          );
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error loading token from storage: $e');
    }
  }

  // Lưu token vào SharedPreferences
  Future<void> _saveTokenToStorage(String token, String? refreshToken, User? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      
      if (refreshToken != null) {
        await prefs.setString(_keyRefreshToken, refreshToken);
      }
      
      if (user != null) {
        await prefs.setString(_keyUserId, user.id);
        await prefs.setString(_keyUsername, user.username);
        if (user.email != null) {
          await prefs.setString(_keyEmail, user.email!);
        }
        if (user.fullName != null) {
          await prefs.setString(_keyFullName, user.fullName!);
        }
      }
    } catch (e) {
      print('Error saving token to storage: $e');
    }
  }

  // Xóa token khỏi SharedPreferences
  Future<void> _clearTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyFullName);
    } catch (e) {
      print('Error clearing token from storage: $e');
    }
  }

  // Login method
  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate input
      if (identifier.isEmpty || password.isEmpty) {
        _isLoading = false;
        _isAuthenticated = false;
        _errorMessage = 'Tên đăng nhập và mật khẩu không được để trống';
        notifyListeners();
        return false;
      }

      // Call real API
      final response = await ApiService.post(
        '/api/v1/public/auth/login',
        body: {
          'identifiers': identifier,
          'password': password,
        },
        requireAuth: false,
      );

      // Parse response - Backend returns access_token and refresh_token in data
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final loginResponse = LoginResponse.fromJson(data);

      _isLoading = false;
      _isAuthenticated = true;
      _token = loginResponse.accessToken;
      _refreshToken = loginResponse.refreshToken;
      
      // Create user from identifier for now
      // TODO: Fetch user profile from API
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: identifier,
      );
      
      // Set token for future API calls
      ApiService.setAccessToken(_token);
      
      // Save to SharedPreferences
      await _saveTokenToStorage(_token!, _refreshToken, _currentUser);
      
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

  // Logout method
  Future<void> logout() async {
    // Sign out khỏi Google để lần sau có thể chọn tài khoản khác
    await GoogleAuthService.signOut();
    
    // Xóa token khỏi SharedPreferences
    await _clearTokenFromStorage();
    
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
      
      // Set token for API calls
      ApiService.setAccessToken(_token);
      
      // Lưu token vào SharedPreferences
      await _saveTokenToStorage(_token!, _refreshToken, _currentUser);
      
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

