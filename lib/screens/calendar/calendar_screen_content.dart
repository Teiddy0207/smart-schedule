import 'package:flutter/material.dart';

class CalendarScreenContent extends StatefulWidget {
  const CalendarScreenContent({super.key});

  @override
  State<CalendarScreenContent> createState() => _CalendarScreenContentState();
}

class _CalendarScreenContentState extends State<CalendarScreenContent> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Month selector
          _buildMonthSelector(),
          const SizedBox(height: 20),
          // Calendar grid
          _buildCalendarGrid(),
          const SizedBox(height: 30),
          // Selected date info
          _buildSelectedDateInfo(),
        ],
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
            color: Colors.blue.withOpacity(0.2),
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
          color: Colors.black.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
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
          // Calendar days
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
                    // Ngày của tháng trước
                    displayDay = daysInPreviousMonth + dayNumber;
                    isCurrentMonth = false;
                  } else if (dayNumber > daysInMonth) {
                    // Ngày của tháng sau
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

                  return GestureDetector(
                    onTap: isCurrentMonth
                        ? () {
                            setState(() {
                              _selectedDate = DateTime(
                                _currentMonth.year,
                                _currentMonth.month,
                                displayDay,
                              );
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
                                ? const Color(0xFF6366F1).withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
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

  Widget _buildSelectedDateInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ngày đã chọn',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
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

