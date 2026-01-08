import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/date_formatter.dart';
import '../../models/daily_event.dart';
import '../../services/event_service.dart';
import '../../services/calendar_service.dart';
import 'top_notification.dart';

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
  List<DailyEvent> _events = [];
  bool _isLoading = true;

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
    setState(() {
      _isLoading = true;
    });

    final events = await EventService.getEventsForDate(widget.selectedDate);
    
    setState(() {
      _events = events;
      _isLoading = false;
    });
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _events.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingL,
                      ),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        return _buildTimelineEvent(_events[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
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

  Future<void> _deleteEvent(DailyEvent event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sự kiện'),
        content: Text('Bạn có chắc muốn xóa sự kiện "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CalendarService.deleteEvent(event.id);
        if (mounted) {
          TopNotification.success(context, 'Đã xóa sự kiện');
          _loadEvents();
        }
      } catch (e) {
        if (mounted) {
          TopNotification.error(context, 'Lỗi: $e');
        }
      }
    }
  }

  Widget _buildTimelineEvent(DailyEvent event) {
    final height = event.durationHours * 60.0; // 60px per hour

    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.3}, // Chỉ cần vuốt 30%
      confirmDismiss: (_) async {
        await _deleteEvent(event);
        return false; // Don't dismiss automatically, we reload the list
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 16),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Time label
            SizedBox(
              width: 65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event.formattedStartTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    event.formattedEndTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
          
          // Event card
          Expanded(
            child: Container(
              height: event.durationHours <= 0.5 
                  ? 60.0  // 30 min or less
                  : event.durationHours <= 1.0 
                      ? 90.0  // 1 hour
                      : (event.durationHours * 80.0).clamp(90.0, 250.0), // > 1 hour
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                gradient: AppConstants.dashboardAppBarGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (event.durationHours >= 1.0) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (event.durationHours >= 1.0 && event.participants.isNotEmpty) ...[
                    const Spacer(),
                    Row(
                      children: [
                        const Spacer(),
                        ...event.participants.take(3).map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: _buildAvatar(p.avatarColor),
                          );
                        }),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
            ],
          ),
        ),
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
