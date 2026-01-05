import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/group_service.dart';
import '../../services/user_search_service.dart';
import '../../models/group/group_model.dart';
import '../../constants/app_constants.dart';
import 'add_user_to_group.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupDescription; // Mô tả nhóm (optional)
  final Map<String, Map<String, String>>? userInfoMap; // Map user_id -> {name, email} từ create group

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupDescription,
    this.userInfoMap, // Thông tin user từ create group screen
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  GetUsersByGroupIdResponse? _response;
  Map<String, UserSearchResult> _userInfoCache = {}; // Cache thông tin user

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  Future<void> _loadGroupDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final response = await GroupService.getUsersByGroupId(
        authProvider: authProvider,
        groupId: widget.groupId,
      );

      // Lấy thông tin đầy đủ cho các users có provider_name/provider_email null
      // Sử dụng thông tin từ userInfoMap (từ create group screen) hoặc cache
      _userInfoCache.clear();
      final List<GroupUser> updatedUsers = [];
      
      for (final groupUser in response.users) {
        // Nếu user đã có đầy đủ thông tin, giữ nguyên
        if (groupUser.user.providerName.isNotEmpty && groupUser.user.providerEmail.isNotEmpty) {
          updatedUsers.add(groupUser);
          continue;
        }
        
        // Nếu thiếu thông tin, thử lấy từ userInfoMap (từ create group screen)
        String? name;
        String? email;
        
        if (widget.userInfoMap != null && widget.userInfoMap!.containsKey(groupUser.user.id)) {
          final userInfo = widget.userInfoMap![groupUser.user.id]!;
          name = userInfo['name'];
          email = userInfo['email'];
          print('✅ Found user info from userInfoMap for ${groupUser.user.id}: name=$name, email=$email');
        }
        
        // Nếu vẫn không có, thử từ cache
        if ((name == null || name.isEmpty) && _userInfoCache.containsKey(groupUser.user.id)) {
          final cachedInfo = _userInfoCache[groupUser.user.id]!;
          name = cachedInfo.displayName;
          email = cachedInfo.email;
          print('✅ Found user info from cache for ${groupUser.user.id}');
        }
        
        // Nếu có thông tin từ userInfoMap hoặc cache, cập nhật user
        if ((name != null && name.isNotEmpty) || (email != null && email.isNotEmpty)) {
          final updatedUser = User(
            id: groupUser.user.id,
            providerName: name ?? groupUser.user.providerName,
            providerEmail: email ?? groupUser.user.providerEmail,
          );
          updatedUsers.add(GroupUser(
            id: groupUser.id,
            userId: groupUser.userId,
            user: updatedUser,
            groupId: groupUser.groupId,
            group: groupUser.group,
            createdAt: groupUser.createdAt,
          ));
          print('✅ Updated user ${groupUser.user.id} with info: name=${updatedUser.providerName}, email=${updatedUser.providerEmail}');
        } else {
          // Không có thông tin, giữ nguyên (sẽ hiển thị fallback)
          updatedUsers.add(groupUser);
          print('⚠ User ${groupUser.user.id} missing info, will show fallback');
        }
      }
      
      // Cập nhật response với users đã được xử lý
      final updatedResponse = GetUsersByGroupIdResponse(
        groupId: response.groupId,
        group: response.group,
        users: updatedUsers,
      );

      // Nếu response không có thông tin group đầy đủ (name rỗng), cập nhật từ widget
      if (response.group.name.isEmpty && widget.groupName.isNotEmpty) {
        // Tạo một response mới với thông tin group đầy đủ
        final updatedGroup = Group(
          id: response.group.id,
          name: widget.groupName,
          description: response.group.description,
        );
        
        // Tạo response mới với group đã cập nhật
        final updatedResponse = GetUsersByGroupIdResponse(
          groupId: response.groupId,
          group: updatedGroup,
          users: response.users,
        );
        
        if (mounted) {
          setState(() {
            _response = updatedResponse;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _response = response;
            _isLoading = false;
          });
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

  bool _isCurrentUser(String userId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser?.id == userId;
  }

  Future<void> _addMember() async {
    // Lấy danh sách thành viên hiện tại để truyền vào AddUserToGroup
    final existingMembers = _response?.users.map((groupUser) {
      return {
        'id': groupUser.user.id,
        'name': groupUser.user.providerName,
        'email': groupUser.user.providerEmail,
      };
    }).toList() ?? [];

    // Mở màn hình tìm kiếm và thêm thành viên
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUserToGroup(
          existingMembers: existingMembers,
        ),
      ),
    );

    // Nếu có kết quả (user đã chọn), thêm vào nhóm
    if (result != null && result is Map<String, String>) {
      final userId = result['id'];
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể thêm thành viên: thiếu thông tin user ID'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Log để debug
      print('=== Adding member to group ===');
      print('User ID from search result: $userId');
      print('User name: ${result['name']}');
      print('User email: ${result['email']}');
      print('Group ID: ${widget.groupId}');

      // Hiển thị loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Gọi API thêm user vào nhóm
        await GroupService.addUsersToGroup(
          authProvider: authProvider,
          groupId: widget.groupId,
          userIds: [userId],
        );

        // Đóng loading dialog
        if (mounted) {
          Navigator.pop(context); // Đóng loading dialog
        }

        // Hiển thị thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm ${result['name'] ?? result['email'] ?? 'thành viên'} vào nhóm'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Refresh lại danh sách thành viên
        await _loadGroupDetails();
      } catch (e) {
        // Đóng loading dialog
        if (mounted) {
          Navigator.pop(context); // Đóng loading dialog
        }

        // Hiển thị thông báo lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể thêm thành viên: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
        title: Text(
          widget.groupName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _loadGroupDetails,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadGroupDetails,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin nhóm
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên nhóm
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: AppConstants.appBarGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.group,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _response?.group.name ?? widget.groupName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_response?.users.length ?? 0} thành viên',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Mô tả nhóm
                            if (_response?.group.description != null && 
                                _response!.group.description.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mô tả',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _response!.group.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Danh sách thành viên
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Thành viên',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppConstants.gradientEnd.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_response?.users.length ?? 0}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.gradientEnd,
                                    ),
                                  ),
                                ),
                              ],
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
                      ),
                      const SizedBox(height: 12),

                      // Danh sách thành viên
                      if (_response == null || _response!.users.isEmpty)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Chưa có thành viên nào trong nhóm',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._response!.users.map((groupUser) {
                          final isMe = _isCurrentUser(groupUser.userId);
                          
                          // Debug: Log thông tin user
                          print('🎨 Building user card for:');
                          print('  User ID: ${groupUser.user.id}');
                          print('  providerName: "${groupUser.user.providerName}" (isEmpty: ${groupUser.user.providerName.isEmpty})');
                          print('  providerEmail: "${groupUser.user.providerEmail}" (isEmpty: ${groupUser.user.providerEmail.isEmpty})');
                          
                          // Lấy name và email
                          String name = groupUser.user.providerName.trim();
                          String email = groupUser.user.providerEmail.trim();
                          
                          // Nếu không có thông tin, thử lấy từ userInfoMap (từ create group screen)
                          if ((name.isEmpty || email.isEmpty) && widget.userInfoMap != null) {
                            if (widget.userInfoMap!.containsKey(groupUser.user.id)) {
                              final userInfo = widget.userInfoMap![groupUser.user.id]!;
                              print('  ✅ Found in userInfoMap: ${userInfo}');
                              if (name.isEmpty && userInfo['name'] != null && userInfo['name']!.isNotEmpty) {
                                name = userInfo['name']!;
                                print('  ✅ Updated name from userInfoMap: $name');
                              }
                              if (email.isEmpty && userInfo['email'] != null && userInfo['email']!.isNotEmpty) {
                                email = userInfo['email']!;
                                print('  ✅ Updated email from userInfoMap: $email');
                              }
                            }
                          }
                          
                          // Nếu vẫn không có thông tin, thử từ cache
                          if ((name.isEmpty || email.isEmpty) && _userInfoCache.containsKey(groupUser.user.id)) {
                            final cachedInfo = _userInfoCache[groupUser.user.id]!;
                            print('  ✅ Found in cache: ${cachedInfo.displayName}, ${cachedInfo.email}');
                            if (name.isEmpty) {
                              name = cachedInfo.displayName ?? cachedInfo.email;
                            }
                            if (email.isEmpty) {
                              email = cachedInfo.email;
                            }
                          }
                          
                          // Nếu vẫn rỗng, dùng fallback
                          if (name.isEmpty) {
                            name = 'Người dùng';
                            print('  ⚠ Using fallback name: $name');
                          }
                          if (email.isEmpty) {
                            // Thử dùng user ID làm identifier
                            if (groupUser.user.id.length >= 8) {
                              email = 'ID: ${groupUser.user.id.substring(0, 8)}...';
                            } else {
                              email = 'ID: ${groupUser.user.id}';
                            }
                            print('  ⚠ Using fallback email: $email');
                          }
                          
                          print('  📝 Final display: name="$name", email="$email"');
                          
                          return _buildUserCard(
                            name: name,
                            email: email,
                            isMe: isMe,
                          );
                        }),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String email,
    required bool isMe,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tôi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
        ],
      ),
    );
  }
}

