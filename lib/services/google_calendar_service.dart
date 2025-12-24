import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';

/// Model cho Google Calendar Event
class GoogleCalendarEvent {
  final String id;
  final String summary;
  final String? description;
  final DateTime? start;
  final DateTime? end;
  final String? location;
  final String? status;

  GoogleCalendarEvent({
    required this.id,
    required this.summary,
    this.description,
    this.start,
    this.end,
    this.location,
    this.status,
  });

  factory GoogleCalendarEvent.fromJson(Map<String, dynamic> json) {
    // Parse start time
    DateTime? startTime;
    if (json['start'] != null) {
      final startData = json['start'];
      if (startData['dateTime'] != null && startData['dateTime'].toString().isNotEmpty) {
        startTime = DateTime.parse(startData['dateTime']);
      } else if (startData['date'] != null && startData['date'].toString().isNotEmpty) {
        startTime = DateTime.parse(startData['date']);
      }
    }

    // Parse end time
    DateTime? endTime;
    if (json['end'] != null) {
      final endData = json['end'];
      if (endData['dateTime'] != null && endData['dateTime'].toString().isNotEmpty) {
        endTime = DateTime.parse(endData['dateTime']);
      } else if (endData['date'] != null && endData['date'].toString().isNotEmpty) {
        endTime = DateTime.parse(endData['date']);
      }
    }

    return GoogleCalendarEvent(
      id: json['id'] as String,
      summary: json['summary'] as String? ?? 'Không có tiêu đề',
      description: json['description'] as String?,
      start: startTime,
      end: endTime,
      location: json['location'] as String?,
      status: json['status'] as String?,
    );
  }
}

/// Response từ API calendar events
class GoogleCalendarEventsResponse {
  final List<GoogleCalendarEvent> events;
  final String? error;
  final int? totalItems;

  GoogleCalendarEventsResponse({
    required this.events,
    this.error,
    this.totalItems,
  });

  factory GoogleCalendarEventsResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      return GoogleCalendarEventsResponse(
        events: [],
        error: json['error'] as String,
      );
    }

    // Backend trả về data.items (data là Map, items là List)
    List<dynamic> eventsJson = [];
    int? totalItems;
    
    if (json['data'] != null) {
      final data = json['data'];
      
      // Kiểm tra xem data là Map hay List
      if (data is Map<String, dynamic>) {
        // Nếu data là Map, lấy items từ trong Map
        if (data['items'] != null) {
          eventsJson = data['items'] as List<dynamic>;
        }
        // Lấy total_items nếu có
        totalItems = data['total_items'] as int?;
      } else if (data is List) {
        // Nếu data là List trực tiếp (fallback)
        eventsJson = data;
      }
    }

    final events = eventsJson
        .map((e) => GoogleCalendarEvent.fromJson(e as Map<String, dynamic>))
        .toList();

    return GoogleCalendarEventsResponse(
      events: events,
      totalItems: totalItems,
    );
  }
}

class GoogleCalendarService {
  // Get base URL based on platform
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:7070';
    } else {
      return 'http://localhost:7070';
    }
  }

  /// Lấy danh sách events từ Google Calendar
  /// 
  /// [authProvider]: AuthProvider để lấy app JWT token
  /// [timeMin]: Thời gian bắt đầu (optional)
  /// [timeMax]: Thời gian kết thúc (optional)
  /// [maxResults]: Số lượng events tối đa (optional)
  static Future<GoogleCalendarEventsResponse> getCalendarEvents({
    required AuthProvider authProvider,
    DateTime? timeMin,
    DateTime? timeMax,
    int? maxResults,
  }) async {
    try {
      // Lấy app JWT token từ AuthProvider (không phải Google access token)
      final appToken = authProvider.token;
      if (appToken == null || appToken.isEmpty) {
        throw Exception('Chưa đăng nhập. Vui lòng đăng nhập trước.');
      }

      // Kiểm tra xem user đã đăng nhập chưa
      if (!authProvider.isAuthenticated) {
        throw Exception('Chưa đăng nhập. Vui lòng đăng nhập trước.');
      }

      // Build query parameters
      final queryParams = <String, String>{};
      if (timeMin != null) {
        queryParams['timeMin'] = timeMin.toIso8601String();
      }
      if (timeMax != null) {
        queryParams['timeMax'] = timeMax.toIso8601String();
      }
      if (maxResults != null) {
        queryParams['maxResults'] = maxResults.toString();
      }

      // Build URL với query parameters
      final uri = Uri.parse('$_baseUrl/api/v1/public/auth/google/calendar/events')
          .replace(queryParameters: queryParams);

      print('=== Google Calendar API Debug ===');
      print('URL: $uri');
      print('Using app JWT token: ${appToken.substring(0, 20)}...');

      // Gửi request với app JWT token trong header
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $appToken', // App JWT token (backend sẽ tự lấy Google access token từ DB)
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Backend không phản hồi trong 30 giây.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Xử lý response
      if (response.statusCode == 401) {
        throw Exception('Chưa liên kết Google account hoặc token đã hết hạn. Vui lòng đăng nhập lại.');
      }

      if (response.statusCode == 404) {
        throw Exception('Endpoint không tồn tại. Vui lòng kiểm tra backend.');
      }

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorBody?['error'] ?? errorBody?['message'] ?? 'Lỗi không xác định';
        throw Exception('Lỗi khi lấy calendar events: $errorMessage');
      }

      // Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return GoogleCalendarEventsResponse.fromJson(responseData);
    } on http.ClientException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    } on SocketException catch (e) {
      throw Exception('Không thể kết nối đến backend.\n'
          'Vui lòng kiểm tra:\n'
          '1. Backend đang chạy trên port 7070\n'
          '2. URL: $_baseUrl\n'
          '3. Lỗi: ${e.message}');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Lỗi khi lấy calendar events: ${e.toString()}');
    }
  }

  /// Lấy events hôm nay
  static Future<GoogleCalendarEventsResponse> getTodayEvents({
    required AuthProvider authProvider,
    int? maxResults,
  }) {
    final now = DateTime.now();
    // Bắt đầu từ 00:00:00 hôm nay
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    // Kết thúc ở 23:59:59 hôm nay
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return getCalendarEvents(
      authProvider: authProvider,
      timeMin: startOfDay,
      timeMax: endOfDay,
      maxResults: maxResults ?? 50,
    );
  }
}

