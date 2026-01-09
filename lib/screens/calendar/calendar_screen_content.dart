import 'package:flutter/material.dart';
import '../../models/daily_event.dart';
import '../../services/event_service.dart';
import '../../utils/app_logger.dart';

class CalendarScreenContent extends StatefulWidget {
  const CalendarScreenContent({super.key});

  @override
  State<CalendarScreenContent> createState() => _CalendarScreenContentState();
}

class _CalendarScreenContentState extends State<CalendarScreenContent> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<DailyEvent> _monthEvents = [];
  List<DailyEvent> _selectedDateEvents = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMonthEvents();
  }

  Future<void> _loadMonthEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Loading events for month: ${_currentMonth.month}/${_currentMonth.year}');
      final events = await EventService.getEventsForMonth(_currentMonth);
      
      setState(() {
        _monthEvents = events;
        _isLoading = false;
        _updateSelectedDateEvents();
      });
      
      AppLogger.info('Loaded ${events.length} events for month');
    } catch (e) {
      AppLogger.error('Failed to load month events', error: e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải lịch. Vui lòng thử lại.';
      });
    }
  }

  void _updateSelectedDateEvents() {
    _selectedDateEvents = _monthEvents.where((event) {
      return event.date.year == _selectedDate.year &&
          event.date.month == _selectedDate.month &&
          event.date.day == _selectedDate.day;
    }).toList();
  }

  bool _hasEventsOnDay(int day) {
    return _monthEvents.any((event) {
      return event.date.year == _currentMonth.year &&
          event.date.month == _currentMonth.month &&
          event.date.day == day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadMonthEvents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Month selector
            _buildMonthSelector(),
            const SizedBox(height: 20),
            // Calendar grid
            _buildCalendarGrid(),
            const SizedBox(height: 20),
            // Selected date events
            _buildSelectedDateEvents(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7E6DF7),
            Color(0xFF6B5CE6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                );
              });
              _loadMonthEvents();
            },
          ),
          Column(
            children: [
              Text(
                _getMonthName(_currentMonth.month),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
              Text(
                _currentMonth.year.toString(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                );
              });
              _loadMonthEvents();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Tính số tuần cần hiển thị
    final daysToShow = firstDayWeekday - 1 + daysInMonth;
    final weeksCount = (daysToShow / 7).ceil();

    // Ngày của tháng trước
    final previousMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 0);
    final daysInPreviousMonth = previousMonth.day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          width: 1,
          color: Colors.black.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Day labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CalendarDayLabel('T2'),
              _CalendarDayLabel('T3'),
              _CalendarDayLabel('T4'),
              _CalendarDayLabel('T5'),
              _CalendarDayLabel('T6'),
              _CalendarDayLabel('T7'),
              _CalendarDayLabel('CN'),
            ],
          ),
          const SizedBox(height: 16),
          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          // Calendar days
          if (!_isLoading)
            ...List.generate(weeksCount, (weekIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (dayIndex) {
                    final dayNumber = weekIndex * 7 + dayIndex - (firstDayWeekday - 1) + 1;
                    
                    bool isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
                    int displayDay;
                    
                    if (dayNumber <= 0) {
                      displayDay = daysInPreviousMonth + dayNumber;
                      isCurrentMonth = false;
                    } else if (dayNumber > daysInMonth) {
                      displayDay = dayNumber - daysInMonth;
                      isCurrentMonth = false;
                    } else {
                      displayDay = dayNumber;
                    }

                    final date = DateTime(
                      _currentMonth.year,
                      _currentMonth.month,
                      isCurrentMonth ? displayDay : 1,
                    );

                    final isSelected = isCurrentMonth &&
                        _selectedDate.year == date.year &&
                        _selectedDate.month == date.month &&
                        _selectedDate.day == displayDay;

                    final isToday = isCurrentMonth &&
                        displayDay == DateTime.now().day &&
                        _currentMonth.year == DateTime.now().year &&
                        _currentMonth.month == DateTime.now().month;

                    final hasEvents = isCurrentMonth && _hasEventsOnDay(displayDay);

                    return GestureDetector(
                      onTap: isCurrentMonth
                          ? () {
                              setState(() {
                                _selectedDate = DateTime(
                                  _currentMonth.year,
                                  _currentMonth.month,
                                  displayDay,
                                );
                                _updateSelectedDateEvents();
                              });
                            }
                          : null,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : isToday
                                  ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              displayDay.toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isCurrentMonth
                                        ? isToday
                                            ? const Color(0xFF6366F1)
                                            : Colors.black87
                                        : Colors.grey[300],
                                fontSize: 16,
                                fontFamily: 'Lexend',
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            // Event indicator dot
                            if (hasEvents && !isSelected)
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSelectedDateEvents() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
              Text(
                '${_selectedDateEvents.length} sự kiện',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadMonthEvents,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          
          // Events list
          if (_selectedDateEvents.isEmpty && _errorMessage == null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Không có sự kiện',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Events cards
          ..._selectedDateEvents.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(DailyEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: event.isOnline ? const Color(0xFF10B981) : const Color(0xFF6366F1),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${event.startTime} - ${event.endTime}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontFamily: 'Lexend',
                ),
              ),
              const Spacer(),
              if (event.isOnline)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam, size: 14, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'Online',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
            ),
          ),
          if (event.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              event.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontFamily: 'Lexend',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (event.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  event.isOnline ? Icons.link : Icons.location_on,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontFamily: 'Lexend',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          // Participants
          if (event.participants.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                ...event.participants.take(4).map((p) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: p.avatarColor,
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
                if (event.participants.length > 4)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    child: Text(
                      '+${event.participants.length - 4}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return months[month - 1];
  }
}

class _CalendarDayLabel extends StatelessWidget {
  final String label;
  const _CalendarDayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF7E6DF7), Color(0xFF6366F1)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
