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
      initialBottomNavIndex:  0,
      appBar:  PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin:  Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:  BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration:  BoxDecoration(
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
                      icon: const Icon(Icons. search, color: Colors.white),
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
          children: [
            // Year title với nút refresh
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Row(
                children: [
                  const Text(
                    '2025',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // Nút refresh có viền
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF6366F1), width: 2),
                    ),
                    child:  IconButton(
                      padding:  EdgeInsets.zero,
                      icon: const Icon(Icons. refresh, color: Color(0xFF6366F1), size: 20),
                      onPressed:  () {},
                    ),
                  ),
                ],
              ),
            ),

            // Month grid
            Expanded(
              child:  Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthLabels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder:  (context, index) {
                    final label = monthLabels[index];
                    final isActive = index == 3; // Tháng 4 is active

                    return _MonthCard(
                      label: label,
                      active: isActive,
                      onTap: () {
                        // Navigate to month view - không truyền parameter
                        Navigator. of(context).push(
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
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback?  onTap;

  const _MonthCard({
    Key?  key,
    required this.label,
    this.active = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final background = active ?  const Color(0xFF7C3AED) : const Color(0xFFE8E8F4);
    final textColor = active ? Colors.white : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
              :  null,
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}