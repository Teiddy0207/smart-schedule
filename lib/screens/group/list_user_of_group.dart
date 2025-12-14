import 'package:flutter/material.dart';

class ListUserOfGroup extends StatelessWidget {
  final String groupName;
  final String groupId; // Có thể dùng để fetch data từ API sau này

  const ListUserOfGroup({
    super.key,
    required this.groupName,
    required this.groupId,
  });

  // Fake data - danh sách user trong nhóm
  List<Map<String, dynamic>> _getUsersForGroup(String groupId) {
    // Dựa vào groupId, trả về danh sách user tương ứng
    // Hiện tại dùng fake data
    // Có thể mở rộng để trả về dữ liệu khác nhau cho từng nhóm
    switch (groupId) {
      case 'service-part':
        return [
          {
            'name': 'Airbender',
            'email': 'nvquang176@gmai.com',
            'isAdmin': true,
            'isMe': true,
          },
          {
            'name': 'Quang SDS',
            'email': 'nvquang176@gmai.com',
            'isAdmin': false,
            'isMe': false,
          },
          {
            'name': 'Quang SDS',
            'email': 'nvquang176@gmai.com',
            'isAdmin': false,
            'isMe': false,
          },
          {
            'name': 'Quang SDS',
            'email': 'nvquang176@gmai.com',
            'isAdmin': false,
            'isMe': false,
          },
        ];
      default:
        return [
          {
            'name': 'User 1',
            'email': 'user1@example.com',
            'isAdmin': false,
            'isMe': true,
          },
          {
            'name': 'User 2',
            'email': 'user2@example.com',
            'isAdmin': false,
            'isMe': false,
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _getUsersForGroup(groupId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Màu nền xám nhạt
      appBar: AppBar(
        flexibleSpace: Container(
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'List User Of Group',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.group,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Implement group actions
            },
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header bar với tên nhóm
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9C88FF), // tím nhạt
                    Color(0xFF7C3AED), // tím đậm
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    groupName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // TODO: Implement search
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.group,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // TODO: Implement group actions
                    },
                  ),
                ],
              ),
            ),
            // Danh sách user
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserCard(
                    name: user['name'] as String,
                    email: user['email'] as String,
                    isAdmin: user['isAdmin'] as bool,
                    isMe: user['isMe'] as bool,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String email,
    required bool isAdmin,
    required bool isMe,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          
          // Thông tin user
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Text "tôi" nếu là user hiện tại
          if (isMe)
            const Text(
              'tôi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

