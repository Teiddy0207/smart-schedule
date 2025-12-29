import 'package:flutter/material.dart';
import '../services/user_search_service.dart';

/// Widget để tìm kiếm và chọn nhiều users với popup dialog
class UserSearchWidget extends StatefulWidget {
  final List<UserSearchResult> selectedUsers;
  final Function(List<UserSearchResult>) onChanged;
  final String? hintText;

  const UserSearchWidget({
    super.key,
    required this.selectedUsers,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<UserSearchWidget> createState() => _UserSearchWidgetState();
}

class _UserSearchWidgetState extends State<UserSearchWidget> {
  static const _primaryColor = Color(0xFF6C63FF);

  void _openSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserSearchPopup(
        selectedUsers: widget.selectedUsers,
        onConfirm: (users) {
          widget.onChanged(users);
        },
      ),
    );
  }

  void _removeUser(UserSearchResult user) {
    final newList = widget.selectedUsers.where((u) => u.id != user.id).toList();
    widget.onChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected users chips
        if (widget.selectedUsers.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedUsers.map((user) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: _primaryColor,
                  radius: 14,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: Text(
                  user.displayText,
                  style: const TextStyle(fontSize: 14),
                ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeUser(user),
                backgroundColor: _primaryColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Add user button
        InkWell(
          onTap: _openSearchDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_add_outlined, color: _primaryColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.selectedUsers.isEmpty 
                        ? (widget.hintText ?? 'Thêm người tham dự...')
                        : 'Thêm người tham dự khác...',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Popup dialog for searching and selecting users
class UserSearchPopup extends StatefulWidget {
  final List<UserSearchResult> selectedUsers;
  final Function(List<UserSearchResult>) onConfirm;

  const UserSearchPopup({
    super.key,
    required this.selectedUsers,
    required this.onConfirm,
  });

  @override
  State<UserSearchPopup> createState() => _UserSearchPopupState();
}

class _UserSearchPopupState extends State<UserSearchPopup> {
  final TextEditingController _searchController = TextEditingController();
  List<UserSearchResult> _searchResults = [];
  List<UserSearchResult> _tempSelected = [];
  bool _isLoading = false;

  static const _primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedUsers);
    _loadAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);
    final users = await UserSearchService.getAllUsers();
    setState(() {
      _searchResults = users;
      _isLoading = false;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      _loadAllUsers();
      return;
    }

    setState(() => _isLoading = true);
    final users = await UserSearchService.searchUsers(query);
    setState(() {
      _searchResults = users;
      _isLoading = false;
    });
  }

  void _toggleUser(UserSearchResult user) {
    setState(() {
      if (_tempSelected.any((u) => u.id == user.id)) {
        _tempSelected.removeWhere((u) => u.id == user.id);
      } else {
        _tempSelected.add(user);
      }
    });
  }

  bool _isUserSelected(UserSearchResult user) {
    return _tempSelected.any((u) => u.id == user.id);
  }

  void _confirm() {
    widget.onConfirm(_tempSelected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Huỷ',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Text(
                  'Chọn người tham dự',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Xong (${_tempSelected.length})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 16, fontFamily: 'Lexend'),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên hoặc email...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontFamily: 'Lexend',
                  ),
                  prefixIcon: const Icon(Icons.search, color: _primaryColor, size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _loadAllUsers();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  _searchUsers(value);
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Selected count
          if (_tempSelected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Đã chọn: ${_tempSelected.length} người',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() => _tempSelected.clear());
                    },
                    child: const Text(
                      'Bỏ chọn tất cả',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                        child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            return _buildUserItem(_searchResults[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy người dùng',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserSearchResult user) {
    final isSelected = _isUserSelected(user);

    return InkWell(
      onTap: () => _toggleUser(user),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: _primaryColor,
              radius: 22,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name and email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  if (user.displayName != null)
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Lexend',
                      ),
                    ),
                ],
              ),
            ),

            // Checkbox
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? _primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.withValues(alpha: 0.4), width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
