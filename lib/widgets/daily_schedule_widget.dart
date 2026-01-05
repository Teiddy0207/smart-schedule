import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/date_formatter.dart';
import '../../models/daily_event.dart';
import '../../services/event_service.dart';

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
  final ScrollController _scrollController = ScrollController();

  // Height of each event card (approximate)
  static const double _eventCardHeight = 130.0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    // Auto-scroll to the event closest to current time
    if (events.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToClosestEvent();
      });
    }
  }

  /// Find and scroll to the event closest to current time
  void _scrollToClosestEvent() {
    if (_events.isEmpty || !_scrollController.hasClients) return;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    int closestIndex = 0;
    int? closestUpcomingDiff;
    int? closestPastDiff;
    int closestUpcomingIndex = 0;
    int closestPastIndex = 0;

    for (int i = 0; i < _events.length; i++) {
      final event = _events[i];
      final parts = event.startTime.split(':');
      if (parts.length == 2) {
        final eventMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        final diff = eventMinutes - currentMinutes;
        
        if (diff >= 0) {
          // Upcoming event
          if (closestUpcomingDiff == null || diff < closestUpcomingDiff) {
            closestUpcomingDiff = diff;
            closestUpcomingIndex = i;
          }
        } else {
          // Past event
          if (closestPastDiff == null || diff.abs() < closestPastDiff) {
            closestPastDiff = diff.abs();
            closestPastIndex = i;
          }
        }
      }
    }

    // Prefer upcoming event, fallback to past event
    if (closestUpcomingDiff != null) {
      closestIndex = closestUpcomingIndex;
    } else if (closestPastDiff != null) {
      closestIndex = closestPastIndex;
    }

    // Calculate scroll offset
    final offset = closestIndex * _eventCardHeight;
    final maxScroll = _scrollController.position.maxScrollExtent;
    
    _scrollController.animateTo(
      offset.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
            4, // Reduced spacing
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
            4, // Reduced spacing
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
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(), // No overscroll effect
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

  Widget _buildTimelineEvent(DailyEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 50,
            child: Text(
              event.formattedStartTime,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          
          // Event card
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                minHeight: event.durationHours * 50.0 > 100 
                    ? event.durationHours * 50.0 
                    : 100,
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
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    event.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  // Avatars
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
              ),
            ),
          ),
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
