import 'package:flutter/material.dart';
import '../base_screen.dart';
import 'create_group.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  // Fake data - danh sách nhóm
  final List<Map<String, dynamic>> _groups = const [
    {'name': 'Service Part', 'members': 10},
    {'name': 'Cloud Part', 'members': 8},
    {'name': 'AI Part', 'members': 12},
    {'name': 'Trà đá SDS', 'members': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      initialBottomNavIndex: 3,
      appBar: AppBar(
        flexibleSpace: Container( //update lại màu tím
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9C88FF), // tím nhạt
                Color(0xFF7C3AED), // tím đậm
              ],
            ),
          ),
        ),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available,
              color: Color(0xFF7C3AED),
              size: 20,
            ),
          ),
        ),
        title: const Text(
          'Nhóm của bạn',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.search,
                color: Color(0xFF7C3AED),
                size: 20,
              ),
            ),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.add,
                color: Color(0xFF7C3AED),
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateGroup(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          return _buildGroupCard(
            name: group['name'] as String,
            memberCount: group['members'] as int,
          );
        },
      ),
    );
  }

  Widget _buildGroupCard({
    required String name,
    required int memberCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient( // update lại màu tím
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9C88FF), // tím nhạt
            Color(0xFF7C3AED), // tím đậm
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon nhóm
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group,
              color: Color(0xFF7C3AED),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Thông tin nhóm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thành viên: $memberCount',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Icon menu
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Implement menu
            },
          ),
        ],
      ),
    );
  }
}
