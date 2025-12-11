import 'package:flutter/material.dart';

import '../base_screen.dart';
import 'dashboard_month.dart';

class MainDashboardYear extends StatelessWidget {
  const MainDashboardYear({Key? key}) : super(key: key);

  static const List<String> monthLabels = [
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12',
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      initialBottomNavIndex: 0,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Year title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: const [
                  Text(
                    '2025',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  // optional action
                  Icon(Icons.filter_list, color: Colors.white54),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Month grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: LayoutBuilder(builder: (context, constraints) {
                // Calculate crossAxisCount to look good on different widths.
                final width = constraints.maxWidth;
                final crossAxisCount = width > 420 ? 4 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthLabels.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 97 / 80,
                  ),
                  itemBuilder: (context, index) {
                    final label = monthLabels[index];
                    final isActive = index == 3; // Tháng 4 is active in the original design

                    return _MonthCard(
                      label: label,
                      active: isActive,
                      onTap: () {
                        if (isActive) {
                          // Navigate to month view (slide transition)
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 450),
                              pageBuilder: (context, animation, secondaryAnimation) =>
                              const MainDashboardMonth(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                final tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                final offsetAnimation = animation.drive(tween);
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        } else {
                          // simple feedback for non-active months (could be expanded)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Mở $label (chưa có nội dung)')),
                          );
                        }
                      },
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _MonthCard({
    Key? key,
    required this.label,
    this.active = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final background = active ? const Color(0xFF6366F1) : const Color(0xFFE3E4F7);
    final textColor = active ? Colors.white : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: ShapeDecoration(
          color: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shadows: active
              ? const [
            BoxShadow(
              color: Color(0x293666F1),
              blurRadius: 12,
              offset: Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}