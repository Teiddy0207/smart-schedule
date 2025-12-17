import 'package:flutter/material.dart';
import '../base_screen.dart';
import 'dashboard_month.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      initialBottomNavIndex: 0,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: const BoxDecoration(
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 450),
                          pageBuilder: (context, animation, secondaryAnimation) => const MainDashboardMonth(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
                  const SizedBox(width: 6),
                  const Text(
                    'Thứ 5 - 29/4',
                    style: TextStyle(
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

            // "Lịch hôm nay"
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 22, 0, 10),
              child: Text(
                "Lịch hôm nay",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Dynamic Data - Lịch hôm nay
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                children: [
                  _buildHourItem(
                    time: "08.00",
                    child: _buildScheduleCard(
                      title: "Daily Meeting",
                      subtitle: "Online: Google meet",
                      avatars: const [
                      ],
                    ),
                  ),
                  _buildHourItem(
                    time: "14.00",
                    child: _buildScheduleCard(
                      title: "KT Construction System - Cloud Application Group",
                      subtitle: "Offline: Room C3",
                      avatars: const [
                      ],
                    ),
                  ),
                  _buildHourItem(
                    time: "16.00",
                    child: _buildScheduleCard(
                      title: "KT Construction System - Cloud Application Group",
                      subtitle: "Offline: Room C3",
                      avatars: const [
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildHourItem({required String time, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: const TextStyle(
                color: Color(0xFFB4BAC7),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  static Widget _buildScheduleCard({
    required String title,
    required String subtitle,
    required List<String> avatars,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7266EC),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFE9E6FC),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // Avatar nhóm
          Row(
            children: avatars.take(2).map((url) => Padding(
              padding: const EdgeInsets.only(left: 2),
              child: CircleAvatar(
                backgroundImage: NetworkImage(url),
                radius: 18,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}