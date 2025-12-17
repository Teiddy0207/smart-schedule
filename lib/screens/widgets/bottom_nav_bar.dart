import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super. key,
    required this. currentIndex,
    required this. onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors. white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets. symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment:  MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Trang chủ',
                index: 0,
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.calendar_today,
                label: 'Lịch',
                index: 1,
                isSelected: currentIndex == 1,
              ),
              // Nút Add tròn nổi bật
              _buildAddButton(),
              _buildNavItem(
                icon: Icons.group,
                label: 'Nhóm',
                index:  3,
                isSelected: currentIndex == 3,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Cá nhân',
                index: 4,
                isSelected: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Transform.translate(
        offset: const Offset(0, -15),
        child:  Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF7E6DF7),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7E6DF7).withOpacity(0.3),
                blurRadius:  10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets. symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize:  MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF7C3AED)
                  : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? const Color(0xFF7C3AED)
                    :  Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight. normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}