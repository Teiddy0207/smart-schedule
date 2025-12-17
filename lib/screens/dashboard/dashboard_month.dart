import 'package:flutter/material.dart';
import 'dashboard_year.dart';
import '../main_screen.dart';

class MainDashboardMonth extends StatefulWidget {
  const MainDashboardMonth({Key? key}) : super(key: key);

  @override
  State<MainDashboardMonth> createState() => _MainDashboardMonthState();
}

class _MainDashboardMonthState extends State<MainDashboardMonth> {
  int selectedDay = 29;
  int currentMonth = 4;
  int currentYear = 2025;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap:  () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                        const MainDashboardYear(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve:  Curves.easeOutCubic,
                          );
                          return FadeTransition(
                            opacity: curvedAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: const Icon(Icons.chevron_left, color: Color(0xFF6B5CE6), size: 32),
                ),
                const SizedBox(width: 4),
                Text(
                  'Tháng $currentMonth',
                  style:  const TextStyle(
                    color: Color(0xFF6B5CE6),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
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
                    onPressed: () {
                      setState(() {
                        selectedDay = 29;
                        currentMonth = 4;
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
              padding:  const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border:  Border.all(
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
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7E6DF7), Color(0xFF6B5CE6)],
            begin:  Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:  BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: SafeArea(
          child:  Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color:  Colors.white24,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Airbender',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight. bold,
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
                    icon: const Icon(Icons. notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDayHeader() {
    final List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            children: List.generate(7, (col) {
              final dayText = weeks[row][col];
              final dayNum = int.parse(dayText);

              // Xác định loại ngày
              bool isPrevMonth = row == 0 && dayNum > 20;
              bool isNextMonth = row == 4 && dayNum < 10;
              bool isSelected = dayNum == selectedDay && row == 4 && dayText == '29';

              // Màu text
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
                        selectedDay = dayNum;
                      });

                      // Chuyển sang màn hình ngày (MainScreen với tab Trang chủ)
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds:  300),
                          pageBuilder: (context, animation, secondaryAnimation) =>
                          const MainScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves. easeOutCubic,
                            );
                            return FadeTransition(
                              opacity: curvedAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
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

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors. black.withOpacity(0.1),
            blurRadius:  10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:  [
              _buildNavItem(icon: Icons.home, label: 'Trang chủ', isSelected: true),
              _buildNavItem(icon: Icons. calendar_today, label: 'Lịch', isSelected: false),
              const SizedBox(width: 56),
              _buildNavItem(icon: Icons.group, label: 'Nhóm', isSelected: false),
              _buildNavItem(icon: Icons. person, label: 'Cá nhân', isSelected: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected ? const Color(0xFF7C3AED) : Colors.grey[600];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:  color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      height: 56,
      width: 56,
      margin: const EdgeInsets.only(top: 30),
      child: FloatingActionButton(
        onPressed: () {
          // Navigate to create event
        },
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 4,
        shape:  const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}