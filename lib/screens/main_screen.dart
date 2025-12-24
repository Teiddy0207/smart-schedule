import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard/dashboard_screen_content.dart';
import 'group/group_screen_content.dart';
import 'group/create_group.dart';
import 'profile/profile_screen_content.dart';
import 'event/create_event_screen.dart';
import 'calendar/calendar_screen_content.dart';
import '../providers/auth_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/gradient_app_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Builder function để tạo AppBar động với username
  PreferredSizeWidget? _buildAppBar(int index, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.currentUser?.username ?? 'Người dùng';
    
    switch (index) {
      case 0: // Dashboard
        return PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppConstants.dashboardAppBarGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppConstants.radiusXL),
              ),
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
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: AppConstants.iconSizeLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      username,
                      style: const TextStyle(
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
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case 1: // Group
        return GradientAppBar(
          title: 'Nhóm của bạn',
          leading: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available,
                color: AppConstants.gradientEnd,
                size: AppConstants.iconSizeSmall,
              ),
            ),
          ),
          actions: [
            AppBarIconButton(
              icon: Icons.search,
              onPressed: () {},
            ),
            Builder(
              builder: (context) => AppBarIconButton(
                icon: Icons.add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateGroup()),
                  );
                },
              ),
            ),
          ],
        );
      case 2: // Profile - không có AppBar
        return null;
      case 3: // Calendar
        return GradientAppBar(
          title: 'Lịch',
          leading: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppConstants.gradientEnd,
                size: AppConstants.iconSizeSmall,
              ),
            ),
          ),
          actions: [
            AppBarIconButton(
              icon: Icons.today,
              onPressed: () {},
            ),
          ],
        );
      default:
        return null;
    }
  }

  // Danh sách các body tương ứng với bottom nav bar
  // IndexedStack tự động giữ state, không cần PageStorage
  late final List<Widget> _screens = const [
    DashboardScreenContent(),
    GroupScreenContent(),
    ProfileScreenContent(),
    CalendarScreenContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(_currentIndex, context),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.gradientEnd,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 10,
        unselectedFontSize: 10,
        iconSize: 24,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Nhóm'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
        },
        backgroundColor: AppConstants.gradientEnd,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
