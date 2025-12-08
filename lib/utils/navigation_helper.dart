import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/group_screen.dart';
import '../screens/profile_screen.dart';

class NavigationHelper {
  // Map các màn hình tương ứng với index
  static final Map<int, Widget Function()> _routes = {
    0: () => const DashboardScreen(),
    1: () => const CalendarScreen(),
    3: () => const GroupScreen(),
    4: () => const ProfileScreen(),
  };

  // Navigate đến màn hình tương ứng với index
  static void navigateToScreen(BuildContext context, int index, int currentIndex) {
    // Index 2 là "Thêm mới" - không navigate, chỉ mở dialog
    if (index == 2) {
      _showAddDialog(context);
      return;
    }

    // Nếu đang ở cùng màn hình thì không navigate
    if (index == currentIndex) {
      return;
    }

    // Kiểm tra xem có route cho index này không
    if (_routes.containsKey(index)) {
      final screen = _routes[index]!();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  // Hiển thị dialog "Thêm mới"
  static void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm mới'),
        content: const Text('Chức năng thêm mới sẽ được triển khai sau.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

