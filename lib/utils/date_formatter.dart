/// Utility class for date formatting
class DateFormatter {
  // Private constructor to prevent instantiation
  DateFormatter._();

  /// Vietnamese day names
  static const List<String> vietnameseDays = [
    'Chủ nhật',
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
  ];

  /// Format date as "Thứ X - DD/MM"
  static String formatVietnameseDate(DateTime date) {
    final dayName = vietnameseDays[date.weekday % 7];
    return '$dayName - ${date.day}/${date.month}';
  }

  /// Format date as "DD/MM/YYYY"
  static String formatShortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format date as "DD/MM/YYYY HH:mm"
  static String formatDateTime(DateTime date) {
    return '${formatShortDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Alias for formatVietnameseDate
  static String formatDayMonth(DateTime date) {
    return formatVietnameseDate(date);
  }
}

