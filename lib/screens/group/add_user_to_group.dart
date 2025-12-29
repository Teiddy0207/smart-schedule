import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_search_service.dart';

class AddUserToGroup extends StatefulWidget {
  final List<Map<String, String>> existingMembers; // Danh sách thành viên đã có

  const AddUserToGroup({
    super.key,
    required this.existingMembers,
  });

  @override
  State<AddUserToGroup> createState() => _AddUserToGroupState();
}

class _AddUserToGroupState extends State<AddUserToGroup> {
  final TextEditingController _emailController = TextEditingController();
  List<UserSearchResult> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty || query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await UserSearchService.searchUsers(query.trim());
      
      // Lọc bỏ các user đã có trong danh sách thành viên
      final existingEmails = widget.existingMembers.map((m) => m['email']?.toLowerCase()).toSet();
      final filteredResults = results.where((user) {
        return !existingEmails.contains(user.email.toLowerCase());
      }).toList();

      if (mounted) {
        setState(() {
          _searchResults = filteredResults;
          _isSearching = false;
          if (filteredResults.isEmpty && results.isNotEmpty) {
            _errorMessage = 'Người dùng này đã được thêm vào nhóm';
          } else if (filteredResults.isEmpty) {
            _errorMessage = 'Không tìm thấy người dùng với email này';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Lỗi khi tìm kiếm: ${e.toString()}';
        });
      }
    }
  }

  void _selectUser(UserSearchResult user) {
    // Trả về user đã chọn
    Navigator.pop(context, {
      'id': user.id,
      'name': user.displayName ?? user.email,
      'email': user.email,
    });
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
                Color(0xFF9C88FF), // tím nhạt
                Color(0xFF7C3AED), // tím đậm
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
          'Thêm Thành viên',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Input tìm kiếm email
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Nhập email để tìm kiếm',
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
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
                suffixIcon: _emailController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _emailController.clear();
                          setState(() {
                            _searchResults = [];
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {}); // Để cập nhật suffixIcon
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_emailController.text == value) {
                    _searchUsers(value);
                  }
                });
              },
            ),
          ),

          // Hiển thị lỗi hoặc thông báo
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.orange[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading indicator
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),

          // Danh sách kết quả tìm kiếm
          Expanded(
            child: _searchResults.isEmpty && !_isSearching
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Nhập email để tìm kiếm người dùng',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return _buildUserCard(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserSearchResult user) {
    return InkWell(
      onTap: () => _selectUser(user),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
              child: Center(
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Thông tin user
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Icon thêm
            const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

