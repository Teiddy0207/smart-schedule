import 'package:flutter/material.dart';
import '../base_screen.dart';
import 'dashboard_screen.dart';
import 'dashboard_year.dart';

class MainDashboardMonth extends StatefulWidget {
  const MainDashboardMonth({super.key});

  @override
  State<MainDashboardMonth> createState() => _MainDashboardMonthState();
}

class _MainDashboardMonthState extends State<MainDashboardMonth> {
  int selectedDay = 29;
  int currentMonth = 4;
  int currentYear = 2025;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      initialBottomNavIndex: 0,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration:  const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7E6DF7),
                Color(0xFF6B5CE6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets. symmetric(horizontal: 18, vertical: 16),
              child:  Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Airbender',
                    style: TextStyle(
                      color: Colors. white,
                      fontSize: 26,
                      fontWeight:  FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header:  Tháng và nút refresh
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
              child: Row(
                children: [
                  // Nút Back - quay về MainDashboardYear
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap:  () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 450),
                          pageBuilder: (context, animation, secondaryAnimation) =>
                          const MainDashboardYear(),
                          transitionsBuilder:  (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0); // Slide từ trái sang
                            const end = Offset. zero;
                            const curve = Curves.easeInOut;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: const Icon(Icons.chevron_left, color: Color(0xFF6B5CE6), size: 32),
                  ),
                  const SizedBox(width:  6),
                  Text(
                    'Tháng $currentMonth',
                    style:  const TextStyle(
                      color: Color(0xFF6B5CE6),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF6B5CE6), width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF6B5CE6)),
                      onPressed: () {
                        setState(() {
                          currentMonth = 4;
                          currentYear = 2025;
                          selectedDay = 29;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Calendar Card - Expanded để kéo dài
            Expanded(
              child: Padding(
                padding:  const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header ngày trong tuần
                      _buildWeekDayHeader(),
                      const SizedBox(height: 16),
                      // Các ngày trong tháng - Expanded
                      Expanded(
                        child: _buildCalendarDays(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDayHeader() {
    final List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment. spaceAround,
      children:  weekDays.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarDays() {
    int daysInMonth = _getDaysInMonth(currentYear, currentMonth);
    int firstWeekday = _getFirstWeekdayOfMonth(currentYear, currentMonth);

    int prevMonthDays = _getDaysInMonth(
      currentMonth == 1 ? currentYear - 1 : currentYear,
      currentMonth == 1 ?  12 : currentMonth - 1,
    );

    List<int? > days = [];

    int daysFromPrevMonth = (firstWeekday - 1) % 7;
    for (int i = daysFromPrevMonth; i > 0; i--) {
      days.add(-(prevMonthDays - i + 1));
    }

    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }

    int remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (int i = 1; i <= remainingDays; i++) {
        days.add(-100 - i);
      }
    }

    // Tạo danh sách các tuần
    List<List<int? >> weeks = [];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7 > days.length ? days.length :  i + 7));
    }

    return Column(
      children: weeks.map((week) {
        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.map((day) => _buildDayCell(day)).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(int?  day) {
    if (day == null) {
      return const Expanded(child: SizedBox());
    }

    bool isSelected = day == selectedDay && day > 0;
    bool isPrevMonth = day < 0 && day > -100;
    bool isNextMonth = day < -100;

    int displayDay = day;
    if (isPrevMonth) {
      displayDay = -day;
    } else if (isNextMonth) {
      displayDay = -(day + 100);
    }

    Color textColor;
    if (isPrevMonth || isNextMonth) {
      textColor = Colors.grey. shade300;
    } else if (isSelected) {
      textColor = Colors.white;
    } else {
      textColor = Colors. black87;
    }

    // Kích thước ô vuông cố định
    const double squareSize = 44;

    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (! isPrevMonth && !isNextMonth) {
              setState(() {
                selectedDay = day;
              });
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds:  450),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const DashboardScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            }
          },
          child: Container(
            width: squareSize,
            height: squareSize,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment:  Alignment.center,
            child: Text(
              displayDay. toString(),
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstWeekdayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday;
  }
}