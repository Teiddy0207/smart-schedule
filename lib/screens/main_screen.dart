import 'package:flutter/material.dart';
import 'dashboard/dashboard_day.dart';
import 'group/group_screen_content.dart';
import 'group/create_group.dart';
import 'profile/profile_screen_content.dart';
import 'event/create_event_screen.dart';
import 'calendar/calendar_screen_content.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các AppBar tương ứng với mỗi tab
  final List<PreferredSizeWidget?> _appBars = [
    // Tab 0:  Trang chủ
    PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7E6DF7), Color(0xFF6B5CE6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: SafeArea(
          child:  Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets. all(13),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius. circular(50),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors. white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Airbender',
                  style:  TextStyle(
                    color:  Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: IconButton(
                    icon: const Icon(Icons. search, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width:  10),
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
    // Tab 1: Lịch
    PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7E6DF7), Color(0xFF6B5CE6)],
            begin: Alignment. topLeft,
            end:  Alignment.bottomRight,
          ),
          borderRadius: BorderRadius. vertical(bottom: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:  BorderRadius.circular(50),
                  ),
                  child:  const Icon(
                    Icons. calendar_today,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lịch',
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
                    icon: const Icon(Icons.today, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    // Tab 2: Nhóm
    PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Builder(
        builder: (context) => Container(
          decoration: const BoxDecoration(
            gradient:  LinearGradient(
              colors: [Color(0xFF7E6DF7), Color(0xFF6B5CE6)],
              begin: Alignment. topLeft,
              end:  Alignment.bottomRight,
            ),
            borderRadius: BorderRadius. vertical(bottom: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors. white24,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.group,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nhóm của bạn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
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
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateGroup()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    // Tab 3: Cá nhân
    null,
  ];

  // Danh sách các body tương ứng - THỨ TỰ GIỐNG BOTTOM NAV
  late final List<Widget> _screens = const [
    DashboardScreenContent(),   // Trang chủ
    CalendarScreenContent(),    // Lịch
    GroupScreenContent(),       // Nhóm
    ProfileScreenContent(),     // Cá nhân
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors. white,
      appBar: _appBars[_currentIndex],
      body: IndexedStack(index: _currentIndex, children:  _screens),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton:  _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child:  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:  [
              // Trang chủ
              _buildNavItem(
                icon:  Icons.home,
                label: 'Trang chủ',
                index: 0,
              ),
              // Lịch
              _buildNavItem(
                icon: Icons.calendar_today,
                label: 'Lịch',
                index: 1,
              ),
              // Khoảng trống cho FAB
              const SizedBox(width: 56),
              // Nhóm
              _buildNavItem(
                icon: Icons.group,
                label: 'Nhóm',
                index:  2,
              ),
              // Cá nhân
              _buildNavItem(
                icon: Icons.person,
                label: 'Cá nhân',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF7C3AED) : Colors.grey[600];

    return InkWell(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
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
          Navigator. push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
        },
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons. add, color: Colors.white, size: 28),
      ),
    );
  }
}