import 'package:flutter/material.dart';

/// Model đại diện cho một participant trong event
class Participant {
  final String name;
  final Color avatarColor;

  const Participant({
    required this.name,
    required this.avatarColor,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      name: json['name'] as String,
      avatarColor: _parseColor(json['avatarColor'] as String),
    );
  }

  static Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

/// Model đại diện cho một daily event
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
  });

  factory DailyEvent.fromJson(Map<String, dynamic> json) {
    return DailyEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String,
      isOnline: json['isOnline'] as bool,
      participants: (json['participants'] as List<dynamic>)
          .map((p) => Participant.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Tính duration (số giờ) từ startTime và endTime
  int get durationHours {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return end - start;
  }

  /// Parse time string "HH:mm" thành hour number
  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]);
  }

  /// Format startTime để hiển thị (ví dụ: "08.00")
  String get formattedStartTime {
    return startTime.replaceAll(':', '.');
  }
}
