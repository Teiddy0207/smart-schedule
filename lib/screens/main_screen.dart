import 'package:flutter/material.dart' hide debugPrint;
import 'package:provider/provider.dart';
import 'dashboard/dashboard_screen_content.dart';
import 'group/group_screen_content.dart';
import 'group/create_group.dart';
import 'profile/profile_screen_content.dart';
import 'event/create_event_screen.dart';
import 'calendar/calendar_screen_content.dart';
import 'notification/notification_screen.dart';
import '../providers/auth_provider.dart';
import '../constants/app_constants.dart';
import '../services/notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _notificationCount = 0;

  // Danh sách các body tương ứng - THỨ TỰ GIỐNG BOTTOM NAV
  late final List<Widget> _screens = const [
    DashboardScreenContent(),   // Trang chủ
    CalendarScreenContent(),    // Lịch
    GroupScreenContent(),       // Nhóm
    ProfileScreenContent(),     // Cá nhân
  ];

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    final count = await NotificationService.getPendingCount();
    if (mounted) {
      setState(() {
        _notificationCount = count;
      });
    }
  }

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
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationScreen(),
                                ),
                              );
                              _loadNotificationCount();
                            },
                          ),
                        ),
                        if (_notificationCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                _notificationCount > 99 ? '99+' : '$_notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
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
                              MaterialPageRoute(
                                builder: (context) => const CreateGroup(),
                              ),
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
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
          
          // Show success message if event was created
          if (result == true && mounted) {
            _showTopNotification('Sự kiện đã được tạo thành công!');
          }
        },
        backgroundColor: AppConstants.gradientEnd,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _showTopNotification(String message) {
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _TopNotification(
        message: message,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );
    
    Overlay.of(context).insert(overlayEntry);
  }
}

class _TopNotification extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _TopNotification({
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends State<_TopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: GestureDetector(
            onTap: _dismiss,
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < 0) {
                _dismiss();
              }
            },
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lexend',
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
