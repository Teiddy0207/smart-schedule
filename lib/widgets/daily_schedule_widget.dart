import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../services/google_calendar_service.dart';

/// Widget hiển thị lịch theo ngày với timeline
class DailyScheduleWidget extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onShowMonthView;

  const DailyScheduleWidget({
    super.key,
    required this.selectedDate,
    required this.onShowMonthView,
  });

  @override
  State<DailyScheduleWidget> createState() => _DailyScheduleWidgetState();
}

class _DailyScheduleWidgetState extends State<DailyScheduleWidget> {
  List<GoogleCalendarEvent> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void didUpdateWidget(DailyScheduleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Tính toán timeMin và timeMax cho ngày được chọn
      final selectedDate = widget.selectedDate;
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
      final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
      
      final response = await GoogleCalendarService.getCalendarEvents(
        authProvider: authProvider,
        timeMin: startOfDay,
        timeMax: endOfDay,
        maxResults: 50,
      );

      if (!mounted) return;

      if (response.error != null) {
        setState(() {
          _errorMessage = response.error;
          _isLoading = false;
        });
      } else {
        // Filter chỉ lấy events của ngày được chọn
        final selectedYear = selectedDate.year;
        final selectedMonth = selectedDate.month;
        final selectedDay = selectedDate.day;
        
        final filteredEvents = response.events.where((event) {
          if (event.start == null) return false;
          final eventDate = event.start!.toLocal();
          return eventDate.year == selectedYear &&
                 eventDate.month == selectedMonth &&
                 eventDate.day == selectedDay;
        }).toList();
        
        setState(() {
          _events = filteredEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với ngày và nút navigation
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingL,
            AppConstants.spacingXXL,
            AppConstants.spacingL,
            AppConstants.spacingL,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: widget.onShowMonthView,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: const Padding(
                  padding: EdgeInsets.all(AppConstants.spacingS),
                  child: Icon(
                    Icons.chevron_left,
                    color: AppConstants.primaryColor,
                    size: AppConstants.spacing3XL,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                DateFormatter.formatDayMonth(widget.selectedDate),
                style: AppConstants.headingSmall.copyWith(
                  color: AppConstants.primaryColor,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _loadEvents,
                borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: AppConstants.primaryColor,
                    size: AppConstants.iconSizeMedium,
                  ),
                ),
              ),
            ],
          ),
        ),

        // "Lịch hôm nay"
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.spacingL,
            AppConstants.spacingL,
            AppConstants.spacingL,
            AppConstants.spacingM,
          ),
          child: Text(
            'Lịch hôm nay',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),

        // Timeline với events
        Expanded(
          child: _buildEventsList(),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppConstants.primaryColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: AppConstants.spacingM),
              const Text(
                'Lỗi khi tải lịch',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              ElevatedButton(
                onPressed: _loadEvents,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Group events theo giờ bắt đầu
    final Map<int, List<GoogleCalendarEvent>> eventsByHour = {};
    for (var event in _events) {
      if (event.start != null) {
        final hour = event.start!.toLocal().hour;
        if (!eventsByHour.containsKey(hour)) {
          eventsByHour[hour] = [];
        }
        eventsByHour[hour]!.add(event);
      }
    }

    // Sắp xếp events trong mỗi giờ theo thời gian bắt đầu
    eventsByHour.forEach((hour, events) {
      events.sort((a, b) {
        if (a.start == null && b.start == null) return 0;
        if (a.start == null) return 1;
        if (b.start == null) return -1;
        return a.start!.compareTo(b.start!);
      });
    });

    // Nếu không có events nào, hiển thị empty state
    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Không có sự kiện nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Tạo timeline từ 1h đến 24h - hiển thị TẤT CẢ giờ (kể cả trống)
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      children: List.generate(24, (index) {
        final hour = index + 1; // Từ 1h đến 24h
        final hourEvents = eventsByHour[hour] ?? [];
        final timeString = '${hour.toString().padLeft(2, '0')}:00';
        
        if (hourEvents.isEmpty) {
          // Không có event ở giờ này, vẫn hiển thị giờ nhưng trống
          return _buildTimelineHour(
            time: timeString,
            child: const SizedBox.shrink(),
          );
        } else {
          // Có events ở giờ này, hiển thị tất cả
          return Column(
            children: hourEvents.asMap().entries.map((entry) {
              final isFirst = entry.key == 0;
              return _buildTimelineHour(
                time: isFirst ? timeString : '', // Chỉ hiển thị giờ ở event đầu tiên
                child: _buildEventCard(entry.value),
              );
            }).toList(),
          );
        }
      }),
    );
  }

  Widget _buildTimelineHour({required String time, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildEventCard(GoogleCalendarEvent event) {
    // Tính duration
    Duration? duration;
    if (event.start != null && event.end != null) {
      duration = event.end!.difference(event.start!);
    }
    final durationHours = duration != null ? duration.inMinutes / 60.0 : 1.0;

    return Container(
      constraints: BoxConstraints(
        minHeight: durationHours * 50.0 > 100 ? durationHours * 50.0 : 100,
      ),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        gradient: AppConstants.dashboardAppBarGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.summary,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (event.location != null && event.location!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingS),
            Text(
              event.location!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ] else if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingS),
            Text(
              event.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
