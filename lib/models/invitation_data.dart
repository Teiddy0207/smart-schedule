class InvitationData {
  final String id;
  final String eventGoogleId;
  final String creatorId;
  final String status;
  final EventDataDTO eventData;
  final DateTime createdAt;

  InvitationData({
    required this.id,
    required this.eventGoogleId,
    required this.creatorId,
    required this.status,
    required this.eventData,
    required this.createdAt,
  });

  factory InvitationData.fromJson(Map<String, dynamic> json) {
    return InvitationData(
      id: json['id'] ?? '',
      eventGoogleId: json['event_google_id'] ?? '',
      creatorId: json['creator_id'] ?? '',
      status: json['status'] ?? '',
      eventData: EventDataDTO.fromJson(json['event_data'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class EventDataDTO {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String location;
  final String meetingLink;
  final String timezone;

  EventDataDTO({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.meetingLink,
    required this.timezone,
  });

  factory EventDataDTO.fromJson(Map<String, dynamic> json) {
    return EventDataDTO(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      location: json['location'] ?? '',
      meetingLink: json['meeting_link'] ?? '',
      timezone: json['timezone'] ?? '',
    );
  }
}
