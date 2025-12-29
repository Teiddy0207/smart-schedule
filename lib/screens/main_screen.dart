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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _groupRefreshTrigger = 0; // Trigger để refresh GroupScreenContent

  // Danh sách các body tương ứng - THỨ TỰ GIỐNG BOTTOM NAV
  List<Widget> get _screens => [
    const DashboardScreenContent(),   // Trang chủ
    const CalendarScreenContent(),    // Lịch
    GroupScreenContent(
      refreshTrigger: _groupRefreshTrigger,
    ), // Nhóm
    const ProfileScreenContent(),     // Cá nhân
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.currentUser?.username ?? 'Người dùng';

    switch (_currentIndex) {
      case 0: // Trang chủ
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: AppConstants.spacingL,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusCircle,
                        ),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: AppConstants.iconSizeLarge,
                      ),
                    ),
                    const SizedBox(width: AppConstants.radiusM),
                    Expanded(
                      child: Text(
                        username,
                        style: AppConstants.headingMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
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
      case 1: // Lịch
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: AppConstants.spacingL,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusCircle,
                        ),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: AppConstants.iconSizeLarge,
                      ),
                    ),
                    const SizedBox(width: AppConstants.radiusM),
                    const Text(
                      'Lịch',
                      style: AppConstants.headingMedium,
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
        );
      case 2: // Nhóm
        return PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Builder(
            builder: (context) => Container(
              decoration: const BoxDecoration(
                gradient: AppConstants.dashboardAppBarGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppConstants.radiusXL),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: AppConstants.spacingL,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircle,
                          ),
                        ),
                        child: const Icon(
                          Icons.group,
                          color: Colors.white,
                          size: AppConstants.iconSizeLarge,
                        ),
                      ),
                      const SizedBox(width: AppConstants.radiusM),
                      const Text(
                        'Nhóm của bạn',
                        style: AppConstants.headingMedium,
                      ),
                      const Spacer(),
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateGroup(),
                              ),
                            );
                            // Nếu tạo nhóm thành công (result = true), refresh màn hình group
                            if (result == true) {
                              setState(() {
                                _groupRefreshTrigger++; // Tăng trigger để refresh
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      case 3: // Cá nhân
        return null;
      default:
        return null;
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingS,
            vertical: AppConstants.spacingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Trang chủ
              _buildNavItem(
                icon: Icons.home,
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
                index: 2,
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
    final color = isSelected ? AppConstants.gradientEnd : Colors.grey[600];

    return InkWell(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.radiusM,
          vertical: AppConstants.spacingS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: AppConstants.iconSizeMedium,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
        },
        backgroundColor: AppConstants.gradientEnd,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
