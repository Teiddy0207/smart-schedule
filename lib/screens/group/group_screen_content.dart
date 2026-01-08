import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'group_detail_screen.dart';
import '../../constants/app_constants.dart';
import '../../services/group_service.dart';
import '../../models/group/group_model.dart';
import '../../providers/auth_provider.dart';

class GroupScreenContent extends StatefulWidget {
  const GroupScreenContent({super.key, this.refreshTrigger});

  final int? refreshTrigger; // Thay đổi giá trị này sẽ trigger refresh

  @override
  State<GroupScreenContent> createState() => GroupScreenContentState();
}

class GroupScreenContentState extends State<GroupScreenContent> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Group> _groups = [];
  List<Group> _filteredGroups = []; // Danh sách nhóm đã filter theo search
  Map<String, int> _memberCounts = {}; // Map groupId -> memberCount
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterGroups(_searchController.text);
  }

  void _filterGroups(String query) {
    print('filterGroups called with query: "$query"');
    print('Current _groups.length: ${_groups.length}');
    print('Current _isSearching: $_isSearching');
    
    setState(() {
      if (query.trim().isEmpty) {
        _filteredGroups = List.from(_groups); // Copy list để tránh reference issues
        _isSearching = false;
        print('Query empty, showing all ${_filteredGroups.length} groups');
      } else {
        _isSearching = true;
        final lowerQuery = query.toLowerCase().trim();
        _filteredGroups = _groups.where((group) {
          final matches = group.name.toLowerCase().contains(lowerQuery);
          if (matches) {
            print('Group "${group.name}" matches query');
          }
          return matches;
        }).toList();
        print('Query not empty, filtered to ${_filteredGroups.length} groups');
      }
    });
  }

  @override
  void didUpdateWidget(GroupScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu refreshTrigger thay đổi, refresh lại danh sách
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _loadGroups();
    }
  }

  // Refresh khi màn hình được hiển thị lại (ví dụ: sau khi tạo nhóm mới)
  void refreshGroups() {
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.id;
      
      print('=== Load Groups ===');
      print('Current User ID: $currentUserId');
      
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('Không thể xác định user hiện tại. Vui lòng đăng nhập lại.');
      }
      
      final allGroups = await GroupService.getMyGroups(
        authProvider: authProvider,
      );

      print('Total groups from API: ${allGroups.length}');
      for (final group in allGroups) {
        print('  - Group: ${group.name} (ID: ${group.id})');
      }

      // Backend đã filter theo user rồi (PrivateGetGroupsWhereMember)
      // Chỉ cần lấy số lượng thành viên cho mỗi nhóm
      final memberCounts = <String, int>{};
      
      print('Getting member counts for ${allGroups.length} groups (backend already filtered by user)...');
      
      for (final group in allGroups) {
        try {
          final usersResponse = await GroupService.getUsersByGroupId(
            authProvider: authProvider,
            groupId: group.id,
          );
          
          // Lưu số lượng thành viên
          final userCount = usersResponse.users.length;
          memberCounts[group.id] = userCount > 0 ? userCount : 1; // Ít nhất 1 (người tạo)
          
          print('Group "${group.name}" (ID: ${group.id}): $userCount users');
        } catch (e) {
          print('  ⚠ Không thể lấy danh sách users cho nhóm ${group.id}: $e');
          // Nếu không lấy được, giả định ít nhất có 1 thành viên (người tạo)
          memberCounts[group.id] = 1;
        }
      }

      print('=== Final Results ===');
      print('Total groups from API (already filtered by backend): ${allGroups.length}');
      print('Member counts map size: ${memberCounts.length}');
      memberCounts.forEach((groupId, count) {
        print('  - Group ID: $groupId -> $count members');
      });

      if (mounted) {
        setState(() {
          _groups = allGroups; // Backend đã filter rồi, hiển thị tất cả
          _memberCounts = memberCounts;
          _isLoading = false;
        });
        // Áp dụng filter search nếu có
        _filterGroups(_searchController.text);
        print('State updated successfully!');
        print('  - _groups.length: ${_groups.length}');
        print('  - _memberCounts.length: ${_memberCounts.length}');
        print('  - _isSearching: $_isSearching');
        print('  - _filteredGroups.length: ${_filteredGroups.length}');
        print('  - Search query: "${_searchController.text}"');
        print('  - Will display: ${_isSearching ? _filteredGroups.length : _groups.length} groups');
      } else {
        print('Widget not mounted, cannot update state');
      }
    } catch (e) {
      print('Error loading groups: $e');
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
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
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
                onPressed: _loadGroups,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Sử dụng _filteredGroups thay vì _groups để hiển thị
    final displayGroups = _isSearching ? _filteredGroups : _groups;

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nhóm theo tên...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Danh sách nhóm
        Expanded(
          child: displayGroups.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      _isSearching
                          ? 'Không tìm thấy nhóm nào với từ khóa "${_searchController.text}"'
                          : 'Chưa có nhóm nào',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGroups,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayGroups.length,
                    itemBuilder: (context, index) {
                      final group = displayGroups[index];
                      final memberCount = _memberCounts[group.id] ?? 1; // Mặc định ít nhất 1 (người tạo)
                      return _buildGroupCard(
                        context: context,
                        name: group.name,
                        memberCount: memberCount,
                        groupId: group.id,
                      );
                    },
                  ),
                ),
        ),
      ],
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
            builder: (context) => GroupDetailScreen(
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
          gradient: AppConstants.appBarGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
                color: AppConstants.gradientEnd,
                size: AppConstants.iconSizeMedium,
              ),
            ),
            const SizedBox(width: AppConstants.spacingL),
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
