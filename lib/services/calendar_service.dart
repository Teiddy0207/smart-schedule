import 'api_service.dart';
import '../utils/app_logger.dart';

/// Service for Calendar API calls
/// Backend endpoints: /api/v1/private/calendar
class CalendarService {
  static const String _tag = 'CalendarService';
  static const String _basePath = '/api/v1/private/calendar';

  /// Get all calendar connections for current user
  /// GET /api/v1/private/calendar/connections
  static Future<Map<String, dynamic>> getConnections() async {
    AppLogger.info('Getting calendar connections', tag: _tag);
    return await ApiService.get('$_basePath/connections');
  }

  /// Disconnect a calendar provider
  /// DELETE /api/v1/private/calendar/connections/:provider
  static Future<Map<String, dynamic>> disconnectCalendar(String provider) async {
    AppLogger.info('Disconnecting calendar: $provider', tag: _tag);
    return await ApiService.delete('$_basePath/connections/$provider');
  }

  /// Get free/busy information
  /// GET /api/v1/private/calendar/free-busy
  static Future<Map<String, dynamic>> getFreeBusy({
    required String startTime,
    required String endTime,
    List<String>? userIds,
  }) async {
    AppLogger.info('Getting free/busy info', tag: _tag);
    
    String queryParams = 'start_time=$startTime&end_time=$endTime';
    if (userIds != null && userIds.isNotEmpty) {
      queryParams += '&user_ids=${userIds.join(',')}';
    }
    
    return await ApiService.get('$_basePath/free-busy?$queryParams');
  }

  static Future<Map<String, dynamic>> getUserBusy({
    required String userId,
    required String startTime,
    required String endTime,
  }) async {
    AppLogger.info('Getting user busy info', tag: _tag);
    final path = '/api/v1/private/users/$userId/calendar/busy?start_time=$startTime&end_time=$endTime';
    return await ApiService.get(path);
  }

  /// Create a calendar event
  /// POST /api/v1/private/calendar/events
  static Future<Map<String, dynamic>> createEvent({
    required String title,
    String? description,
    required String startTime,
    required String endTime,
    String? timezone,
    List<String>? attendees,
    String? meetingLink,
  }) async {
    AppLogger.info('Creating calendar event: $title', tag: _tag);

    final body = <String, dynamic>{
      'title': title,
      'start_time': startTime,
      'end_time': endTime,
    };

    if (description != null) body['description'] = description;
    if (timezone != null) body['timezone'] = timezone;
    if (attendees != null) body['attendees'] = attendees;
    if (meetingLink != null) body['meeting_link'] = meetingLink;

    return await ApiService.post('$_basePath/events', body: body);
  }
}
