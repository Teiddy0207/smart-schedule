import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_month.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/dashboard_year.dart';
import '../screens/calendar_screen.dart';
import '../screens/group/group_screen.dart';
import '../screens/create_event_screen.dart';
import '../screens/profile_screen.dart';

class NavigationHelper {
  // Map các màn hình tương ứng với index
  static final Map<int, Widget Function()> _routes = {
    0: () => const DashboardScreen(),
    1: () => const CalendarScreen(),
    2: () => const CreateEventScreen(),
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

      final route = PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration. zero,
        reverseTransitionDuration: Duration. zero,
      );

      // Index 2 là "Thêm mới" - dùng push (overlay) thay vì pushReplacement
      if (index == 2) {
        Navigator.of(context).push(route);
      } else {
        // Các màn hình khác dùng pushReplacement (thay thế màn hình)
        Navigator.of(context).pushReplacement(route);
      }
    }
  }

  // ===================== SLIDE TRANSITIONS =====================

  /// Slide from right (forward navigation)
  /// Dùng cho:  Month → Day, Year → Month
  static void slideFromRight(
      BuildContext context,
      Widget destination, {
        bool replace = true,
        int durationMs = 450,
      }) {
    final route = PageRouteBuilder(
      transitionDuration: Duration(milliseconds: durationMs),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end:  end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );

    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator. of(context).push(route);
    }
  }

  /// Slide from left (back navigation)
  /// Dùng cho: Day → Month, Month → Year
  static void slideFromLeft(
      BuildContext context,
      Widget destination, {
        bool replace = true,
        int durationMs = 450,
      }) {
    final route = PageRouteBuilder(
      transitionDuration: Duration(milliseconds: durationMs),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position:  offsetAnimation,
          child: child,
        );
      },
    );

    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  /// Slide from bottom (modal style)
  /// Dùng cho: Create Event, Bottom sheets
  static void slideFromBottom(
      BuildContext context,
      Widget destination, {
        bool replace = false,
        int durationMs = 350,
      }) {
    final route = PageRouteBuilder(
      transitionDuration: Duration(milliseconds: durationMs),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );

    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  /// Fade transition
  /// Dùng cho: Profile, Settings
  static void fadeTransition(
      BuildContext context,
      Widget destination, {
        bool replace = true,
        int durationMs = 300,
      }) {
    final route = PageRouteBuilder(
      transitionDuration:  Duration(milliseconds: durationMs),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder:  (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );

    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  // ===================== SPECIFIC DASHBOARD NAVIGATION =====================

  /// Navigate từ Month view → Day view (click vào ngày)
  static void navigateToDayView(BuildContext context, {String? selectedDate}) {
    slideFromRight(context, const DashboardScreen());
  }

  /// Navigate từ Day view → Month view (back)
  static void navigateToMonthView(BuildContext context) {
    slideFromLeft(context, const MainDashboardMonth());
  }

  /// Navigate từ Month view → Year view (back)
  static void navigateToYearView(BuildContext context) {
    slideFromLeft(context, const MainDashboardYear());
  }

  /// Navigate từ Year view → Month view (click vào tháng)
  static void navigateToMonthViewFromYear(BuildContext context, {int? selectedMonth}) {
    slideFromRight(context, const MainDashboardMonth());
  }

  // ===================== UTILITY METHODS =====================

  /// Pop với custom transition
  static void popWithTransition(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Check nếu có thể pop
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  /// Pop đến route cụ thể
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  /// Clear tất cả và navigate đến màn hình mới
  static void clearAndNavigate(BuildContext context, Widget destination) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
          (route) => false,
    );
  }
}