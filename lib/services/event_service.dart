import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/daily_event.dart';

/// Service để đọc và quản lý daily events từ JSON
class EventService {
  static List<DailyEvent>? _cachedEvents;

  /// Đọc tất cả events từ file JSON
  static Future<List<DailyEvent>> loadEvents() async {
    if (_cachedEvents != null) {
      return _cachedEvents!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/daily_events.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> eventsJson = jsonData['events'] as List<dynamic>;
      
      _cachedEvents = eventsJson
          .map((e) => DailyEvent.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return _cachedEvents!;
    } catch (e) {
      // Trả về list rỗng nếu có lỗi
      return [];
    }
  }

  /// Lấy events theo ngày cụ thể
  static Future<List<DailyEvent>> getEventsForDate(DateTime date) async {
    final allEvents = await loadEvents();
    
    return allEvents.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  /// Clear cache để reload data
  static void clearCache() {
    _cachedEvents = null;
  }
}
