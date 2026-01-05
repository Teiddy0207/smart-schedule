import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/group_service.dart';
import 'group_detail_screen.dart';
import 'add_user_to_group.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  
  // Danh sách thành viên (sẽ được thêm sau khi có API thêm thành viên)
  List<Map<String, String>> _members = [];

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  Future<void> _addMember() async {
    // Mở màn hình tìm kiếm và thêm thành viên
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUserToGroup(
          existingMembers: _members,
        ),
      ),
    );

    // Nếu có kết quả (user đã chọn), thêm vào danh sách
    if (result != null && result is Map<String, String>) {
      setState(() {
        // Kiểm tra xem user đã có trong danh sách chưa
        final email = result['email']?.toLowerCase();
        final isDuplicate = _members.any(
          (member) => member['email']?.toLowerCase() == email,
        );
        
        if (!isDuplicate) {
          _members.add({
            'id': result['id'] ?? '',
            'name': result['name'] ?? '',
            'email': result['email'] ?? '',
          });
        }
      });
    }
  }

  Future<void> _createGroup() async {
    // Validate input
    if (_groupNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên nhóm';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final response = await GroupService.createGroup(
        authProvider: authProvider,
        name: _groupNameController.text.trim(),
        description: _groupDescriptionController.text.trim(),
      );

      if (mounted) {
        // Kiểm tra xem có ID nhóm không
        if (response.group.id.isNotEmpty) {
          // Thêm các thành viên vào nhóm sau khi tạo nhóm thành công
          if (_members.isNotEmpty) {
            print('Adding ${_members.length} members to group ${response.group.id}...');
            
            // Lấy danh sách user IDs từ _members
            final userIds = _members
                .map((member) => member['id'])
                .where((id) => id != null && id.isNotEmpty)
                .cast<String>()
                .toList();
            
            if (userIds.isNotEmpty) {
              try {
                // Gọi API một lần để thêm tất cả users
                await GroupService.addUsersToGroup(
                  authProvider: authProvider,
                  groupId: response.group.id,
                  userIds: userIds,
                );
                
                print('✅ Added ${userIds.length} members to group successfully');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tạo nhóm thành công! Đã thêm ${userIds.length} thành viên.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('⚠ Failed to add members: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tạo nhóm thành công nhưng không thể thêm thành viên: ${e.toString().replaceFirst('Exception: ', '')}'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tạo nhóm thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo nhóm thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          
          // Tạo map user_id -> {name, email} để truyền sang GroupDetailScreen
          final Map<String, Map<String, String>> userInfoMap = {};
          for (final member in _members) {
            final userId = member['id'];
            if (userId != null && userId.isNotEmpty) {
              userInfoMap[userId] = {
                'name': member['name'] ?? '',
                'email': member['email'] ?? '',
              };
            }
          }
          
          // Có ID, điều hướng đến màn hình nhóm mới vừa tạo
          // Sử dụng push thay vì pushReplacement để có thể quay lại và refresh
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailScreen(
                groupName: response.group.name,
                groupId: response.group.id,
                userInfoMap: userInfoMap.isNotEmpty ? userInfoMap : null,
              ),
            ),
          ).then((_) {
            // Khi quay lại từ màn hình chi tiết, pop về màn hình trước với result để trigger refresh
            Navigator.pop(context, true); // true = đã tạo nhóm thành công, trigger refresh
          });
        } else {
          // Không có ID (backend không trả về), pop về màn hình trước với result để trigger refresh
          Navigator.pop(context, true); // true = đã tạo nhóm thành công
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo nhóm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7E6DF7), // tím nhạt
                Color(0xFF6B5CE6), // tím đậm
              ],
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tạo Nhóm Mới',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Tên Nhóm
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: 'Tên Nhóm',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Input Mô tả Nhóm
            TextField(
              controller: _groupDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Mô tả Nhóm',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Phần Thành viên
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thành viên',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addMember,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Thêm Thành viên'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3), // Màu xanh dương giống nút Tạo Nhóm
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Danh sách thành viên
            if (_members.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Chưa có thành viên nào',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ..._members.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                return _buildMemberCard(
                  name: member['name']!,
                  email: member['email']!,
                  onRemove: () => _removeMember(index),
                );
              }),
            
            const SizedBox(height: 24),
            
            // Hiển thị lỗi nếu có
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Nút Tạo Nhóm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Tạo Nhóm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard({
    required String name,
    required String email,
    required VoidCallback onRemove,
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
          
          // Thông tin thành viên
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
          
          // Nút Xóa
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
