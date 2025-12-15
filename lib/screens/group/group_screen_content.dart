import 'package:flutter/material.dart';
import 'create_group.dart';
import 'list_user_of_group.dart';

class GroupScreenContent extends StatelessWidget {
  const GroupScreenContent({super.key});

  final List<Map<String, dynamic>> _groups = const [
    {'name': 'Service Part', 'members': 10, 'id': 'service-part'},
    {'name': 'Cloud Part', 'members': 8, 'id': 'cloud-part'},
    {'name': 'AI Part', 'members': 12, 'id': 'ai-part'},
    {'name': 'Trà đá SDS', 'members': 5, 'id': 'tra-da-sds'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return _buildGroupCard(
          context: context,
          name: group['name'] as String,
          memberCount: group['members'] as int,
          groupId: group['id'] as String,
        );
      },
    );
  }

  Widget _buildGroupCard({
    required BuildContext context,
    required String name,
    required int memberCount,
    required String groupId,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListUserOfGroup(
              groupName: name,
              groupId: groupId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9C88FF),
              Color(0xFF7C3AED),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
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
            IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
