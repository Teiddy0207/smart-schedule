import 'package:flutter/material.dart';

/// Model đại diện cho một participant/attendee trong event
class Participant {
  final String name;
  final String? email;
  final Color avatarColor;

  const Participant({
    required this.name,
    this.email,
    required this.avatarColor,
  });

  /// Parse từ JSON file (legacy)
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      name: json['name'] as String,
      email: json['email'] as String?,
      avatarColor: _parseColor(json['avatarColor'] as String? ?? '#6C63FF'),
    );
  }

  /// Parse từ Google Calendar API attendee
  factory Participant.fromGoogleCalendar(Map<String, dynamic> json) {
    final email = json['email'] as String? ?? '';
    final displayName = json['displayName'] as String? ?? email.split('@').first;
    
    return Participant(
      name: displayName,
      email: email,
      avatarColor: _generateColorFromEmail(email),
    );
  }

  static Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  /// Generate consistent color from email
  static Color _generateColorFromEmail(String email) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
    ];
    return colors[email.hashCode.abs() % colors.length];
  }
}

/// Model đại diện cho một calendar event
class DailyEvent {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final bool isOnline;
  final List<Participant> participants;
  final String? meetingLink;
  final String? description;

  const DailyEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.isOnline,
    required this.participants,
    this.meetingLink,
    this.description,
  });

  /// Parse từ JSON file (legacy)
  factory DailyEvent.fromJson(Map<String, dynamic> json) {
    return DailyEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => Participant.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Parse từ Google Calendar API event
  factory DailyEvent.fromGoogleCalendar(Map<String, dynamic> json) {
    // Parse start time
    final startData = json['start'] as Map<String, dynamic>?;
    final endData = json['end'] as Map<String, dynamic>?;
    
    DateTime startDateTime;
    DateTime endDateTime;
    String startTimeStr;
    String endTimeStr;
    
    if (startData?['dateTime'] != null) {
      // Timed event
      startDateTime = DateTime.parse(startData!['dateTime'] as String);
      endDateTime = DateTime.parse(endData?['dateTime'] as String? ?? startData['dateTime'] as String);
      startTimeStr = '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';
      endTimeStr = '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // All-day event
      startDateTime = DateTime.parse(startData?['date'] as String? ?? DateTime.now().toIso8601String());
      endDateTime = DateTime.parse(endData?['date'] as String? ?? startDateTime.toIso8601String());
      startTimeStr = '00:00';
      endTimeStr = '23:59';
    }

    // Parse attendees
    final attendeesList = json['attendees'] as List<dynamic>? ?? [];
    final participants = attendeesList
        .map((a) => Participant.fromGoogleCalendar(a as Map<String, dynamic>))
        .toList();

    // Check if online meeting
    final hangoutLink = json['hangoutLink'] as String?;
    final conferenceData = json['conferenceData'] as Map<String, dynamic>?;
    final meetLink = hangoutLink ?? 
        (conferenceData?['entryPoints'] as List<dynamic>?)
            ?.firstWhere((e) => e['entryPointType'] == 'video', orElse: () => {})['uri'] as String?;
    
    final isOnline = meetLink != null && meetLink.isNotEmpty;
    final location = json['location'] as String? ?? (isOnline ? 'Online Meeting' : '');

    return DailyEvent(
      id: json['id'] as String? ?? '',
      title: json['summary'] as String? ?? 'Untitled Event',
      subtitle: json['description'] as String? ?? '',
      date: startDateTime,
      startTime: startTimeStr,
      endTime: endTimeStr,
      location: location,
      isOnline: isOnline,
      participants: participants,
      meetingLink: meetLink,
      description: json['description'] as String?,
    );
  }

  /// Tính duration (số giờ) từ startTime và endTime
  double get durationHours {
    final startMinutes = _parseTimeToMinutes(startTime);
    final endMinutes = _parseTimeToMinutes(endTime);
    final diffMinutes = endMinutes - startMinutes;
    return diffMinutes > 0 ? diffMinutes / 60.0 : 1.0;
  }

  /// Parse time string "HH:mm" thành total minutes
  int _parseTimeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = parts.length > 1 ? int.parse(parts[1]) : 0;
    return hours * 60 + minutes;
  }

  /// Format startTime để hiển thị (ví dụ: "08.00")
  String get formattedStartTime {
    return startTime.replaceAll(':', '.');
  }

  /// Format endTime để hiển thị (ví dụ: "09.30")
  String get formattedEndTime {
    return endTime.replaceAll(':', '.');
  }
}
