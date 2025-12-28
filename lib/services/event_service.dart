import '../models/daily_event.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

/// Service để đọc và quản lý calendar events từ Google Calendar API
class EventService {
  static const String _tag = 'EventService';
  static List<DailyEvent>? _cachedEvents;
  static DateTime? _cacheDate;

  /// Load events từ Google Calendar API
  /// [timeMin] và [timeMax] là khoảng thời gian muốn lấy events (RFC3339 format)
  static Future<List<DailyEvent>> loadEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Default: lấy events trong 7 ngày tới
      final now = DateTime.now();
      final start = startDate ?? now;
      final end = endDate ?? now.add(const Duration(days: 7));

      final timeMin = start.toUtc().toIso8601String();
      final timeMax = end.toUtc().toIso8601String();

      AppLogger.info('Loading events from Google Calendar API', tag: _tag);
      AppLogger.info('Time range: $timeMin to $timeMax', tag: _tag);

      // Gọi Backend API
      final response = await ApiService.get(
        '/api/v1/public/auth/google/calendar/events?time_min=$timeMin&time_max=$timeMax',
      );

      if (response['status'] == 200 && response['data'] != null) {
        final eventsData = response['data']['items'] as List<dynamic>? ?? [];
        
        final events = eventsData
            .map((e) => DailyEvent.fromGoogleCalendar(e as Map<String, dynamic>))
            .toList();

        // Sort by start time
        events.sort((a, b) => a.date.compareTo(b.date));

        _cachedEvents = events;
        _cacheDate = now;

        AppLogger.info('Loaded ${events.length} events from Google Calendar', tag: _tag);
        return events;
      } else {
        AppLogger.warning('No events returned from API', tag: _tag);
        return [];
      }
    } catch (e) {
      AppLogger.error('Failed to load events from Google Calendar', 
          tag: _tag, error: e);
      return [];
    }
  }

  /// Lấy events theo ngày cụ thể
  static Future<List<DailyEvent>> getEventsForDate(DateTime date) async {
    try {
      // Lấy events cho ngày cụ thể
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final events = await loadEvents(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      return events.where((event) {
        return event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day;
      }).toList();
    } catch (e) {
      AppLogger.error('Failed to get events for date: $date', tag: _tag, error: e);
      return [];
    }
  }

  /// Lấy events cho tuần hiện tại
  static Future<List<DailyEvent>> getEventsForWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return loadEvents(startDate: weekStart, endDate: weekEnd);
  }

  /// Lấy events cho tháng hiện tại
  static Future<List<DailyEvent>> getEventsForMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return loadEvents(startDate: startOfMonth, endDate: endOfMonth);
  }

  /// Clear cache để reload data
  static void clearCache() {
    _cachedEvents = null;
    _cacheDate = null;
    AppLogger.info('Event cache cleared', tag: _tag);
  }

  /// Kiểm tra cache có còn valid không (valid trong 5 phút)
  static bool isCacheValid() {
    if (_cachedEvents == null || _cacheDate == null) return false;
    return DateTime.now().difference(_cacheDate!).inMinutes < 5;
  }
}
