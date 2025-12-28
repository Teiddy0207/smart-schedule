import 'api_service.dart';
import '../utils/app_logger.dart';

/// Service for Meeting API calls
/// Backend endpoints: /api/v1/private/meetings
class MeetingService {
  static const String _tag = 'MeetingService';
  static const String _basePath = '/api/v1/private/meetings';

  /// Create a new meeting
  /// POST /api/v1/private/meetings
  static Future<Map<String, dynamic>> createMeeting({
    required String title,
    String? description,
    required int durationMinutes,
    String? timezone,
    required List<String> participantEmails,
    Map<String, dynamic>? preferences,
  }) async {
    AppLogger.info('Creating meeting: $title', tag: _tag);

    final body = <String, dynamic>{
      'title': title,
      'duration_minutes': durationMinutes,
      'participants': participantEmails.map((e) => {'email': e}).toList(),
    };

    if (description != null) body['description'] = description;
    if (timezone != null) body['timezone'] = timezone;
    if (preferences != null) body['preferences'] = preferences;

    return await ApiService.post(_basePath, body: body);
  }

  /// Get all meetings for current user
  /// GET /api/v1/private/meetings
  static Future<Map<String, dynamic>> getMyMeetings({
    int page = 1,
    int pageSize = 10,
  }) async {
    AppLogger.info('Getting my meetings', tag: _tag);
    return await ApiService.get('$_basePath?page=$page&page_size=$pageSize');
  }

  /// Get a specific meeting by ID
  /// GET /api/v1/private/meetings/:id
  static Future<Map<String, dynamic>> getMeeting(String meetingId) async {
    AppLogger.info('Getting meeting: $meetingId', tag: _tag);
    return await ApiService.get('$_basePath/$meetingId');
  }

  /// Update a meeting
  /// PUT /api/v1/private/meetings/:id
  static Future<Map<String, dynamic>> updateMeeting(
    String meetingId, {
    String? title,
    String? description,
    int? durationMinutes,
    String? timezone,
    List<String>? participantEmails,
    Map<String, dynamic>? preferences,
  }) async {
    AppLogger.info('Updating meeting: $meetingId', tag: _tag);

    final body = <String, dynamic>{};

    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (durationMinutes != null) body['duration_minutes'] = durationMinutes;
    if (timezone != null) body['timezone'] = timezone;
    if (participantEmails != null) {
      body['participants'] = participantEmails.map((e) => {'email': e}).toList();
    }
    if (preferences != null) body['preferences'] = preferences;

    return await ApiService.put('$_basePath/$meetingId', body: body);
  }

  /// Delete a meeting
  /// DELETE /api/v1/private/meetings/:id
  static Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    AppLogger.info('Deleting meeting: $meetingId', tag: _tag);
    return await ApiService.delete('$_basePath/$meetingId');
  }

  /// Find available time slots for a meeting
  /// POST /api/v1/private/meetings/:id/find-slots
  static Future<Map<String, dynamic>> findAvailableSlots(
    String meetingId, {
    String? earliestDate,
    String? latestDate,
    int? maxResults,
  }) async {
    AppLogger.info('Finding slots for meeting: $meetingId', tag: _tag);

    final body = <String, dynamic>{};
    if (earliestDate != null) body['earliest_date'] = earliestDate;
    if (latestDate != null) body['latest_date'] = latestDate;
    if (maxResults != null) body['max_results'] = maxResults;

    return await ApiService.post('$_basePath/$meetingId/find-slots', body: body);
  }

  /// Schedule a meeting at a specific time
  /// POST /api/v1/private/meetings/:id/schedule
  static Future<Map<String, dynamic>> scheduleMeeting(
    String meetingId, {
    required String scheduledAt, // RFC3339 format
    String? meetingLink,
  }) async {
    AppLogger.info('Scheduling meeting: $meetingId at $scheduledAt', tag: _tag);

    final body = <String, dynamic>{
      'scheduled_at': scheduledAt,
    };
    if (meetingLink != null) body['meeting_link'] = meetingLink;

    return await ApiService.post('$_basePath/$meetingId/schedule', body: body);
  }

  /// Send invitations for a meeting
  /// POST /api/v1/private/meetings/:id/send-invitations
  static Future<Map<String, dynamic>> sendInvitations(String meetingId) async {
    AppLogger.info('Sending invitations for meeting: $meetingId', tag: _tag);
    return await ApiService.post('$_basePath/$meetingId/send-invitations');
  }
}
