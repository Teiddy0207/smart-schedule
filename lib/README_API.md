# Hướng dẫn sử dụng API Service

## Cấu trúc thư mục

```
lib/
├── config/
│   └── api_config.dart          # Cấu hình API (base URL, endpoints, timeout)
├── core/
│   ├── api_client.dart          # HTTP client với Dio
│   └── api_exception.dart      # Xử lý lỗi API
├── models/
│   └── auth/
│       ├── login_request.dart   # Model request đăng nhập
│       └── login_response.dart  # Model response đăng nhập
├── services/
│   └── auth_service.dart        # Service layer - gọi API trực tiếp
├── repositories/
│   └── auth_repository.dart     # Repository layer - xử lý business logic + local storage
└── screens/
    └── login_screen.dart        # UI màn hình đăng nhập
```

## Cách sử dụng

### 1. Cấu hình API

Chỉnh sửa `lib/config/api_config.dart` để thay đổi base URL:

```dart
static const String baseUrl = 'http://localhost:7070';
```

### 2. Sử dụng trong màn hình

```dart
// Khởi tạo
final apiClient = ApiClient();
final authService = AuthService(apiClient);
final authRepository = AuthRepository(authService);

// Đăng nhập
try {
  final response = await authRepository.login('email@example.com', 'password');
  // Xử lý response
} on ApiException catch (e) {
  // Xử lý lỗi
  print(e.message);
}
```

### 3. Thêm API mới

1. Tạo model request/response trong `lib/models/`
2. Thêm endpoint vào `api_config.dart`
3. Tạo method trong service (`lib/services/`)
4. Tạo method trong repository (`lib/repositories/`)

### 4. Chạy code generation (nếu sửa models)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Hướng dẫn ghép API và gọi API

### Bước 1: Cấu hình kết nối API

#### 1.1. Thiết lập Base URL

Mở file `lib/config/api_config.dart` và cập nhật base URL của backend:

```dart
class ApiConfig {
  // Thay đổi URL này thành URL backend của bạn
  static const String baseUrl = 'http://localhost:7070';
  // Hoặc production: 'https://api.yourapp.com'
  
  // Các endpoint
  static const String loginEndpoint = '/auth/login';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
}
```

#### 1.2. Kiểm tra format API response

Đảm bảo response từ backend có format phù hợp với model. Ví dụ:

**Request:**
```json
POST /auth/login
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response thành công:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_here",
  "user": {
    "id": "123",
    "email": "user@example.com",
    "name": "Nguyễn Văn A",
    "avatar": "https://example.com/avatar.jpg"
  },
  "message": "Đăng nhập thành công"
}
```

**Response lỗi:**
```json
{
  "message": "Email hoặc mật khẩu không đúng",
  "error": "INVALID_CREDENTIALS"
}
```

### Bước 2: Cập nhật Models (nếu cần)

Nếu API response khác với model hiện tại, cập nhật file `lib/models/auth/login_response.dart`:

```dart
@JsonSerializable()
class LoginResponse {
  final String? token;
  final String? refreshToken;
  final User? user;
  final String? message;
  
  // Thêm các field khác nếu cần
  // final int? statusCode;
  // final Map<String, dynamic>? data;
}
```

Sau đó chạy code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Bước 3: Gọi API từ UI

#### 3.1. Khởi tạo Repository trong main.dart

File `lib/main.dart` đã được cấu hình sẵn:

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo API client và services
    final apiClient = ApiClient();
    final authService = AuthService(apiClient);
    final authRepository = AuthRepository(authService);

    return MaterialApp(
      home: LoginScreen(authRepository: authRepository),
    );
  }
}
```

#### 3.2. Sử dụng trong LoginScreen

File `lib/screens/login_screen.dart` đã có sẵn logic gọi API:

```dart
Future<void> _handleLogin() async {
  // Validate form
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // Gọi API đăng nhập
    final response = await widget.authRepository.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Xử lý khi thành công
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Đăng nhập thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Điều hướng đến màn hình chính
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => HomeScreen()),
      // );
    }
  } on ApiException catch (e) {
    // Xử lý lỗi từ API
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // Xử lý lỗi không xác định
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

### Bước 4: Flow hoàn chỉnh

```
UI (LoginScreen)
    ↓
Repository (AuthRepository)
    ↓
Service (AuthService)
    ↓
API Client (ApiClient với Dio)
    ↓
Backend API
    ↓
Response → Parse JSON → Model → Repository → UI
```

### Ví dụ: Thêm API mới (Get User Profile)

#### 4.1. Thêm endpoint vào `api_config.dart`:

```dart
static const String getUserProfileEndpoint = '/user/profile';
```

#### 4.2. Tạo model response (nếu cần):

```dart
// lib/models/user/user_profile_response.dart
@JsonSerializable()
class UserProfileResponse {
  final User user;
  final Map<String, dynamic>? additionalInfo;
  
  UserProfileResponse({
    required this.user,
    this.additionalInfo,
  });
  
  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseFromJson(json);
}
```

#### 4.3. Thêm method vào Service:

```dart
// lib/services/auth_service.dart
Future<UserProfileResponse> getUserProfile() async {
  final response = await _apiClient.get(
    ApiConfig.getUserProfileEndpoint,
  );
  return UserProfileResponse.fromJson(response.data);
}
```

#### 4.4. Thêm method vào Repository:

```dart
// lib/repositories/auth_repository.dart
Future<UserProfileResponse> getUserProfile() async {
  try {
    final response = await _authService.getUserProfile();
    // Có thể lưu user data vào local storage
    if (response.user != null) {
      await _saveUser(response.user!);
    }
    return response;
  } catch (e) {
    rethrow;
  }
}
```

#### 4.5. Sử dụng trong UI:

```dart
// Trong widget của bạn
Future<void> loadUserProfile() async {
  try {
    final profile = await authRepository.getUserProfile();
    setState(() {
      _user = profile.user;
    });
  } on ApiException catch (e) {
    print('Lỗi: ${e.message}');
  }
}
```

### Bước 5: Xử lý Authentication Token

Token được tự động lưu khi đăng nhập thành công. Để sử dụng token trong các request khác:

#### 5.1. Cập nhật ApiClient để tự động thêm token:

Mở `lib/core/api_client.dart` và uncomment phần interceptor:

```dart
void _setupInterceptors() {
  _dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Lấy token từ SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        return handler.next(options);
      },
    ),
  );
}
```

#### 5.2. Kiểm tra token trước khi gọi API:

```dart
Future<void> someProtectedApi() async {
  final token = await authRepository.getToken();
  if (token == null) {
    // Chưa đăng nhập, điều hướng về màn hình login
    return;
  }
  
  // Gọi API được bảo vệ
  // Token sẽ tự động được thêm vào header
}
```

### Bước 6: Test API

#### 6.1. Test với Postman/Insomnia:

1. Test endpoint login:
   - Method: POST
   - URL: `http://localhost:7070/auth/login`
   - Body (JSON):
     ```json
     {
       "email": "test@example.com",
       "password": "password123"
     }
     ```

#### 6.2. Debug trong Flutter:

Thêm logging vào `api_client.dart`:

```dart
onRequest: (options, handler) {
  print('Request: ${options.method} ${options.path}');
  print('Headers: ${options.headers}');
  print('Data: ${options.data}');
  return handler.next(options);
},
onResponse: (response, handler) {
  print('Response: ${response.statusCode}');
  print('Data: ${response.data}');
  return handler.next(response);
},
```

### Troubleshooting

#### Lỗi kết nối:
- Kiểm tra base URL có đúng không
- Kiểm tra backend có đang chạy không
- Kiểm tra firewall/network

#### Lỗi 401 Unauthorized:
- Kiểm tra token có được lưu đúng không
- Kiểm tra format Authorization header
- Token có thể đã hết hạn

#### Lỗi parse JSON:
- Kiểm tra response format có khớp với model không
- Chạy lại code generation: `flutter pub run build_runner build --delete-conflicting-outputs`

## Lưu ý

- Token được tự động lưu vào SharedPreferences khi đăng nhập thành công
- API client tự động xử lý lỗi và throw `ApiException`
- Có thể thêm interceptor để tự động thêm token vào header (xem `api_client.dart`)
- Luôn sử dụng try-catch khi gọi API
- Sử dụng `mounted` check trước khi update UI trong async functions

