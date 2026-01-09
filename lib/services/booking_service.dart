import 'api_service.dart';
import '../utils/app_logger.dart';

/// Service for Booking API calls
/// Backend endpoints: /api/v1/private/booking
class BookingService {
  static const String _tag = 'BookingService';
  static const String _basePath = '/api/v1/private/booking';

  /// Get personal booking URL
  /// GET /api/v1/private/booking/personal-url
  static Future<Map<String, dynamic>> getPersonalUrl() async {
    AppLogger.info('Getting personal booking URL', tag: _tag);
    return await ApiService.get('$_basePath/personal-url');
  }

  /// Get week statistics
  /// GET /api/v1/private/booking/week-statistics
  static Future<Map<String, dynamic>> getWeekStatistics() async {
    AppLogger.info('Getting week statistics', tag: _tag);
    return await ApiService.get('$_basePath/week-statistics');
  }
}

