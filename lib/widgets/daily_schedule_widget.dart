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
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

  Widget _buildTimelineEvent(DailyEvent event) {
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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
