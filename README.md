# SmartMeet - Lịch Hẹn Thông Minh

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-Private-red)

**Ứng dụng tìm lịch trống tự động - Giải pháp thông minh cho việc sắp xếp lịch họp nhóm**

</div>

---

## 📋 Mục lục

- [Tổng quan dự án](#-tổng-quan-dự-án)
- [Tính năng chính](#-tính-năng-chính)
- [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
- [Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [Cài đặt](#-cài-đặt)
- [Cấu hình](#-cấu-hình)
- [Chạy ứng dụng](#-chạy-ứng-dụng)
- [Cấu trúc dự án](#-cấu-trúc-dự-án)
- [API Backend](#-api-backend)
- [Đóng góp](#-đóng-góp)

---

## 🎯 Tổng quan dự án

**SmartMeet** là một ứng dụng di động được thiết kế để loại bỏ cơn ác mộng của việc sắp xếp lịch họp nhóm: *"Khi nào mọi người rảnh?"*.

Ứng dụng cho phép người dùng:
- Kết nối lịch cá nhân (Google Calendar, Outlook Calendar) vào hệ thống
- Tự động quét lịch của tất cả thành viên được mời
- Tìm ra ngay các khung giờ mà tất cả mọi người đều rảnh
- Tạo và quản lý các nhóm làm việc
- Tổ chức cuộc họp một cách thông minh và hiệu quả

Thay vì phải tạo một "poll" (khảo sát) thủ công hoặc hỏi qua lại trong nhóm chat, **SmartMeet** sẽ tự động xử lý tất cả và đưa ra gợi ý thời gian phù hợp nhất.

---

## ✨ Tính năng chính

### 🔐 Xác thực
- **Đăng nhập Google**: Đăng nhập nhanh chóng và an toàn bằng tài khoản Google
- **Quản lý phiên đăng nhập**: Tự động lưu trữ và quản lý token xác thực

### 📅 Quản lý Lịch
- **Đồng bộ Google Calendar**: Tự động đồng bộ sự kiện từ Google Calendar
- **Xem lịch theo ngày/tuần/tháng**: Nhiều chế độ xem lịch linh hoạt
- **Tạo sự kiện mới**: Tạo và quản lý sự kiện trực tiếp từ ứng dụng
- **Thống kê lịch**: Xem thống kê sự kiện và thời gian trong tuần

### 👥 Quản lý Nhóm
- **Tạo nhóm**: Tạo các nhóm làm việc với tên và mô tả
- **Thêm thành viên**: Tìm kiếm và thêm thành viên vào nhóm
- **Xem chi tiết nhóm**: Xem danh sách thành viên và thông tin nhóm
- **Quản lý thành viên**: Thêm/xóa thành viên khỏi nhóm

### 📊 Dashboard
- **Tổng quan lịch**: Xem nhanh các sự kiện sắp tới
- **Thống kê tuần**: Số lượng sự kiện và tổng thời gian trong tuần
- **Thông báo**: Nhận và quản lý thông báo về lời mời họp

### 👤 Hồ sơ Cá nhân
- **Thông tin người dùng**: Xem và quản lý thông tin cá nhân
- **Lịch đã liên kết**: Xem các lịch đã kết nối (Google Calendar)
- **URL đặt lịch**: Quản lý URL đặt lịch cá nhân
- **Thống kê**: Xem thống kê sự kiện và thời gian

---

## 🛠 Công nghệ sử dụng

### Frontend
- **Flutter 3.9.2+**: Framework đa nền tảng
- **Dart 3.9.2+**: Ngôn ngữ lập trình
- **Provider**: Quản lý state
- **Dio/HTTP**: Gọi API REST
- **Shared Preferences**: Lưu trữ dữ liệu local
- **Google Sign In**: Xác thực Google
- **Flutter SVG**: Hiển thị icon SVG
- **Intl**: Định dạng ngày tháng

### Backend API
- RESTful API (chạy trên `localhost:7070` hoặc `10.0.2.2:7070` cho Android emulator)
- JWT Authentication
- Google Calendar API integration

---

## 💻 Yêu cầu hệ thống

### Phát triển
- **Flutter SDK**: 3.9.2 hoặc cao hơn
- **Dart SDK**: 3.9.2 hoặc cao hơn
- **Android Studio** hoặc **VS Code** với Flutter extension
- **Android SDK** (cho Android)
- **Xcode** (cho iOS - chỉ trên macOS)

### Thiết bị/Emulator
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Windows**: Windows 10+
- **macOS**: macOS 10.14+
- **Linux**: Ubuntu 18.04+

### Backend
- Backend API server chạy trên `http://localhost:7070`
- Google OAuth 2.0 credentials đã được cấu hình

---

## 📦 Cài đặt

### 1. Clone repository

```bash
git clone <repository-url>
cd smart-schedule
```

### 2. Cài đặt Flutter dependencies

```bash
flutter pub get
```

### 3. Cài đặt dependencies cho code generation (nếu cần)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ⚙️ Cấu hình

### 1. Cấu hình Backend API

File `lib/services/api_service.dart` đã được cấu hình tự động:
- **Android Emulator**: `http://10.0.2.2:7070`
- **iOS Simulator/Desktop**: `http://localhost:7070`

Nếu backend chạy trên địa chỉ khác, sửa trong file `lib/services/api_service.dart`:

```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:7070'; // Thay đổi port nếu cần
  } else {
    return 'http://localhost:7070'; // Thay đổi port nếu cần
  }
}
```

### 2. Cấu hình Google Sign-In

#### Android
1. Mở file `android/app/build.gradle.kts`
2. Đảm bảo `minSdkVersion` >= 21
3. Thêm Google Services (nếu cần)

#### iOS
1. Mở file `ios/Runner/Info.plist`
2. Thêm URL scheme cho Google Sign-In (nếu cần)

### 3. Cấu hình Backend

Đảm bảo backend API đang chạy và có các endpoint sau:
- `POST /api/v1/public/auth/google/verify` - Xác thực Google
- `GET /api/v1/private/products/groups` - Lấy danh sách nhóm
- `POST /api/v1/private/products/groups` - Tạo nhóm mới
- `GET /api/v1/private/products/groups/{id}/users` - Lấy thành viên nhóm
- `GET /api/v1/public/auth/google/calendar/events` - Lấy sự kiện từ Google Calendar
- Và các endpoint khác...

---

## 🚀 Chạy ứng dụng

### 1. Kiểm tra thiết bị/emulator

```bash
flutter devices
```

### 2. Chạy ứng dụng

#### Chế độ Debug (Development)
```bash
flutter run
```

#### Chạy trên thiết bị cụ thể
```bash
flutter run -d <device-id>
```

#### Chế độ Release (Production)
```bash
flutter run --release
```

### 3. Hot Reload

Khi ứng dụng đang chạy:
- Nhấn `r` trong terminal để hot reload
- Nhấn `R` để hot restart
- Nhấn `q` để thoát

### 4. Build ứng dụng

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Windows
```bash
flutter build windows --release
```

#### macOS
```bash
flutter build macos --release
```

#### Linux
```bash
flutter build linux --release
```

---

## 📁 Cấu trúc dự án

```
smart-schedule/
├── lib/
│   ├── constants/          # Hằng số ứng dụng (màu sắc, styles, ...)
│   │   └── app_constants.dart
│   ├── models/             # Data models
│   │   ├── auth/           # Models cho authentication
│   │   ├── group/          # Models cho groups
│   │   └── ...
│   ├── providers/          # State management (Provider)
│   │   └── auth_provider.dart
│   ├── screens/            # Các màn hình chính
│   │   ├── login/          # Màn hình đăng nhập
│   │   ├── dashboard/      # Màn hình dashboard
│   │   ├── calendar/       # Màn hình lịch
│   │   ├── group/          # Màn hình quản lý nhóm
│   │   ├── event/          # Màn hình tạo/quản lý sự kiện
│   │   ├── notification/   # Màn hình thông báo
│   │   ├── profile/         # Màn hình hồ sơ
│   │   └── main_screen.dart # Màn hình chính với navigation
│   ├── services/           # API services
│   │   ├── api_service.dart        # Base API service
│   │   ├── google_auth_service.dart # Google authentication
│   │   ├── google_calendar_service.dart # Google Calendar API
│   │   ├── group_service.dart       # Group API
│   │   ├── event_service.dart      # Event API
│   │   ├── calendar_service.dart   # Calendar API
│   │   ├── notification_service.dart # Notification API
│   │   └── ...
│   ├── utils/              # Utilities
│   │   ├── app_logger.dart
│   │   └── date_formatter.dart
│   ├── widgets/            # Reusable widgets
│   │   ├── daily_schedule_widget.dart
│   │   ├── month_calendar_widget.dart
│   │   ├── google_icon.dart
│   │   └── ...
│   └── main.dart           # Entry point
├── android/                # Android platform code
├── ios/                    # iOS platform code
├── windows/                # Windows platform code
├── macos/                  # macOS platform code
├── linux/                  # Linux platform code
├── web/                    # Web platform code
├── test/                   # Unit tests
├── pubspec.yaml            # Dependencies
└── README.md               # File này
```

---

## 🔌 API Backend

### Base URL
- **Android Emulator**: `http://10.0.2.2:7070`
- **iOS/Desktop**: `http://localhost:7070`

### Các endpoint chính

#### Authentication
- `POST /api/v1/public/auth/google/verify` - Xác thực Google và lấy token

#### Groups
- `GET /api/v1/private/products/groups` - Lấy danh sách nhóm của user
- `POST /api/v1/private/products/groups` - Tạo nhóm mới
- `GET /api/v1/private/products/groups/{groupId}/users` - Lấy thành viên nhóm
- `POST /api/v1/private/products/groups/users` - Thêm thành viên vào nhóm

#### Calendar
- `GET /api/v1/public/auth/google/calendar/events` - Lấy sự kiện từ Google Calendar
- `POST /api/v1/private/calendar/events` - Tạo sự kiện mới

#### Users
- `GET /api/v1/private/auth/users/search` - Tìm kiếm người dùng

#### Notifications
- `GET /api/v1/private/invitations` - Lấy danh sách lời mời
- `GET /api/v1/private/invitations/count` - Đếm số lời mời chưa đọc
- `POST /api/v1/private/invitations/{id}/accept` - Chấp nhận lời mời
- `POST /api/v1/private/invitations/{id}/decline` - Từ chối lời mời

#### Booking
- `GET /api/v1/private/booking/personal-url` - Lấy URL đặt lịch cá nhân
- `GET /api/v1/private/booking/week-statistics` - Lấy thống kê tuần

### Authentication
Tất cả các endpoint private yêu cầu header:
```
Authorization: Bearer <access_token>
```

---

## 🧪 Testing

```bash
# Chạy tất cả tests
flutter test

# Chạy test với coverage
flutter test --coverage
```

---

## 📝 Ghi chú phát triển

### State Management
Ứng dụng sử dụng **Provider** pattern để quản lý state:
- `AuthProvider`: Quản lý trạng thái đăng nhập và thông tin user

### API Service
Tất cả API calls được xử lý thông qua `ApiService`:
- Tự động thêm Authorization header
- Xử lý lỗi thống nhất
- Logging tự động

### Error Handling
- Network errors được xử lý và hiển thị thông báo phù hợp
- API errors được log và hiển thị cho user

---

## 🤝 Đóng góp

Dự án này là private. Nếu bạn muốn đóng góp, vui lòng liên hệ với maintainer.

---

## 📄 License

Dự án này là private và không được phân phối công khai.

---

## 👥 Tác giả

**SmartMeet Development Team**

---

## 📞 Liên hệ

Nếu có câu hỏi hoặc vấn đề, vui lòng tạo issue trong repository hoặc liên hệ trực tiếp với team phát triển.

---

<div align="center">

**Được xây dựng với ❤️ bằng Flutter**

</div>
