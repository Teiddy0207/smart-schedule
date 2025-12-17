import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Header:  2025 và nút refresh
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                const Text(
                  '2025',
                  style: TextStyle(
                    color: Color(0xFF6B5CE6),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:  Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF6B5CE6), width: 2),
                  ),
                  child:  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.refresh, color: Color(0xFF6B5CE6), size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Month Grid
          Expanded(
            child:  Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthLabels.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final label = monthLabels[index];
                  final isActive = index == 3; // Tháng 4

                  return _MonthCard(
                    label: label,
                    active: isActive,
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 350),
                          pageBuilder: (context, animation, secondaryAnimation) =>
                          const MainDashboardMonth(),
                          transitionsBuilder:  (context, animation, secondaryAnimation, child) {
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve:  Curves.easeOutCubic,
                            );
                            return FadeTransition(
                              opacity: curvedAnimation,
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
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7E6DF7), Color(0xFF6B5CE6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children:  [
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
                    fontWeight: FontWeight. bold,
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
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child:  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:  [
              _buildNavItem(icon: Icons.home, label: 'Trang chủ', isSelected: true),
              _buildNavItem(icon: Icons.calendar_today, label: 'Lịch', isSelected: false),
              const SizedBox(width: 56), // Space for FAB
              _buildNavItem(icon: Icons.group, label: 'Nhóm', isSelected: false),
              _buildNavItem(icon: Icons. person, label: 'Cá nhân', isSelected: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected ? const Color(0xFF7C3AED) : Colors.grey[600];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:  color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      height: 56,
      width:  56,
      margin: const EdgeInsets.only(top: 30),
      child: FloatingActionButton(
        onPressed: () {
          // Navigate to create event
        },
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons. add, color: Colors.white, size: 28),
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
    final background = active ? const Color(0xFF7C3AED) : const Color(0xFFE8E8F4);
    final textColor = active ? Colors.white : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          boxShadow:  active
              ? [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              blurRadius:  12,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            textAlign:  TextAlign.center,
            style: TextStyle(
              color:  textColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}