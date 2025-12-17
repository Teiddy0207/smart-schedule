import 'package:flutter/material.dart';
import 'dashboard_month.dart';
import 'dashboard_year.dart';

class DashboardScreenContent extends StatefulWidget {
  const DashboardScreenContent({super.key});

  @override
  State<DashboardScreenContent> createState() => _DashboardScreenContentState();
}

class _DashboardScreenContentState extends State<DashboardScreenContent> {
  // 0: Day view, 1: Month view, 2: Year view
  int _currentView = 0;
  int _selectedDay = 29;
  int _selectedMonth = 4;
  int _selectedYear = 2025;

  @override
  Widget build(BuildContext context) {
    return Container(
      color:  const Color(0xFFF5F5F7),
      child: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 1:
        return _buildMonthView();
      case 2:
        return _buildYearView();
      default:
        return _buildDayView();
    }
  }

  // ==================== DAY VIEW ====================
  Widget _buildDayView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header:  < Thứ 5 - 29/4
        Padding(
          padding:  const EdgeInsets.fromLTRB(16, 22, 16, 0),
          child: Row(
            children:  [
              InkWell(
                borderRadius: BorderRadius. circular(12),
                onTap: () {
                  setState(() {
                    _currentView = 1; // Chuyển sang Month view
                  });
                },
                child: const Icon(Icons.chevron_left, color: Color(0xFF6B5CE6), size: 32),
              ),
              const SizedBox(width:  6),
              Text(
                'Thứ 5 - $_selectedDay/$_selectedMonth',
                style:  const TextStyle(
                  color: Color(0xFF6B5CE6),
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6B5CE6), width: 2),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.refresh, color: Color(0xFF6B5CE6), size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 22, 0, 10),
          child: Text(
            "Lịch hôm nay",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight. bold),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            children: [
              _buildHourItem(
                time: "08.00",
                child: _buildScheduleCard(
                  title: "Daily Meeting",
                  subtitle: "Online: Google meet",
                ),
              ),
              _buildHourItem(
                time: "14.00",
                child: _buildScheduleCard(
                  title: "KT Construction System - Cloud Application Group",
                  subtitle: "Offline: Room C3",
                ),
              ),
              _buildHourItem(
                time: "16.00",
                child: _buildScheduleCard(
                  title:  "KT Construction System - Cloud Application Group",
                  subtitle: "Offline: Room C3",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== MONTH VIEW ====================
  Widget _buildMonthView() {
    return Column(
      children: [
        // Header: < Tháng 4
        Padding(
          padding:  const EdgeInsets.fromLTRB(16, 22, 16, 0),
          child: Row(
            children:  [
              InkWell(
                borderRadius: BorderRadius. circular(12),
                onTap: () {
                  setState(() {
                    _currentView = 2; // Chuyển sang Year view
                  });
                },
                child: const Icon(Icons.chevron_left, color: Color(0xFF6B5CE6), size: 32),
              ),
              const SizedBox(width: 4),
              Text(
                'Tháng $_selectedMonth',
                style: const TextStyle(
                  color:  Color(0xFF6B5CE6),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration:  BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6B5CE6), width: 2),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.refresh, color: Color(0xFF6B5CE6), size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedDay = 29;
                      _selectedMonth = 4;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Calendar Card
        Expanded(
          child:  Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 1,
                  color: Colors.black.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildWeekDayHeader(),
                  const SizedBox(height: 12),
                  Expanded(child: _buildCalendarGrid()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== YEAR VIEW ====================
  Widget _buildYearView() {
    final List<String> monthLabels = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];

    return Column(
      children: [
        // Header: 2025
        Padding(
          padding: const EdgeInsets. fromLTRB(20, 22, 20, 0),
          child: Row(
            children: [
              Text(
                '$_selectedYear',
                style:  const TextStyle(
                  color: Color(0xFF6B5CE6),
                  fontSize:  28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration:  BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6B5CE6), width: 2),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.refresh, color: Color(0xFF6B5CE6), size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),

        // Month Grid
        Expanded(
          child:  Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: GridView. builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: monthLabels.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio:  1.0,
              ),
              itemBuilder: (context, index) {
                final label = monthLabels[index];
                final isActive = index == _selectedMonth - 1;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMonth = index + 1;
                      _currentView = 1; // Chuyển sang Month view
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF7C3AED) : const Color(0xFFE8E8F4),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isActive
                          ? [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.3),
                          blurRadius:  12,
                          offset: const Offset(0, 4),
                        )
                      ]
                          :  null,
                    ),
                    child: Center(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isActive ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ==================== CALENDAR HELPERS ====================
  Widget _buildWeekDayHeader() {
    final List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      mainAxisAlignment:  MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final List<List<String>> weeks = [
      ['29', '30', '31', '1', '2', '3', '4'],
      ['5', '6', '7', '8', '9', '10', '11'],
      ['12', '13', '14', '15', '16', '17', '18'],
      ['19', '20', '21', '22', '23', '24', '25'],
      ['26', '27', '28', '29', '30', '1', '2'],
    ];

    return Column(
      children: List.generate(weeks.length, (row) {
        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:  List.generate(7, (col) {
              final dayText = weeks[row][col];
              final dayNum = int.parse(dayText);

              bool isPrevMonth = row == 0 && dayNum > 20;
              bool isNextMonth = row == 4 && dayNum < 10;
              bool isSelected = dayNum == _selectedDay && ! isPrevMonth && !isNextMonth;

              Color textColor;
              if (isPrevMonth || isNextMonth) {
                textColor = Colors.grey. shade300;
              } else if (isSelected) {
                textColor = Colors.white;
              } else {
                textColor = const Color(0xFF1E293B);
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (! isPrevMonth && !isNextMonth) {
                      setState(() {
                        _selectedDay = dayNum;
                        _currentView = 0; // Chuyển về Day view
                      });
                    }
                  },
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
                        borderRadius: BorderRadius. circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dayText,
                        style:  TextStyle(
                          color:  textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // ==================== SCHEDULE HELPERS ====================
  Widget _buildHourItem({required String time, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: const TextStyle(
                color: Color(0xFFB4BAC7),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width:  12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7266EC),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors. white,
              fontWeight: FontWeight.w700,
              fontSize: 19,
            ),
          ),
          const SizedBox(height:  7),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFE9E6FC),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}