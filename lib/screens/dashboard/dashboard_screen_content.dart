import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dashboard_month.dart';

class DashboardScreenContent extends StatelessWidget {
  const DashboardScreenContent({super.key});

  String _formatDate(DateTime date) {
    final vietnameseDays = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
    final dayName = vietnameseDays[date.weekday % 7];
    return '$dayName - ${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) => const MainDashboardMonth(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(-1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          final offsetAnimation = animation.drive(tween);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  },
                  child: const Icon(Icons.chevron_left, color: Color(0xFF6B5CE6), size: 32),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(DateTime.now()),
                  style: const TextStyle(
                    color: Color(0xFF6B5CE6),
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF6B5CE6)),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 22, 0, 10),
            child: Text(
              "Lịch hôm nay",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Color(0xFFB4BAC7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có sự kiện nào hôm nay',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
