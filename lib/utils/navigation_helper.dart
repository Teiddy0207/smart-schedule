import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/group/group_screen.dart';
import '../screens/create_event_screen.dart';
import '../screens/profile_screen.dart';

class NavigationHelper {
  // Map các màn hình tương ứng với index
  static final Map<int, Widget Function()> _routes = {
    0: () => const DashboardScreen(),
    1: () => const CalendarScreen(),
    2: () => const CreateEventScreen(), // Thêm mới sự kiện
    3: () => const GroupScreen(),
    4: () => const ProfileScreen(),
  };

  // Navigate đến màn hình tương ứng với index
  static void navigateToScreen(BuildContext context, int index, int currentIndex) {
    // Nếu đang ở cùng màn hình thì không navigate
    if (index == currentIndex) {
      return;
    }

    // Kiểm tra xem có route cho index này không
    if (_routes.containsKey(index)) {
      final screen = _routes[index]!();
      
      // Index 2 là "Thêm mới" - dùng push (overlay) thay vì pushReplacement
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      } else {
        // Các màn hình khác dùng pushReplacement (thay thế màn hình)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      }
    }
  }
}

