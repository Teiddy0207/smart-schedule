import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'list_user_of_group.dart';
import '../../constants/app_constants.dart';
import '../../services/group_service.dart';
import '../../models/group/group_model.dart';
import '../../providers/auth_provider.dart';

class GroupScreenContent extends StatefulWidget {
  const GroupScreenContent({super.key});

  @override
  State<GroupScreenContent> createState() => _GroupScreenContentState();
}

class _GroupScreenContentState extends State<GroupScreenContent> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Group> _groups = [];
  Map<String, int> _memberCounts = {}; // Map groupId -> memberCount

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final groups = await GroupService.getMyGroups(
        authProvider: authProvider,
      );

      // Lấy số lượng thành viên cho mỗi nhóm
      final memberCounts = <String, int>{};
      for (final group in groups) {
        try {
          final usersResponse = await GroupService.getUsersByGroupId(
            authProvider: authProvider,
            groupId: group.id,
          );
          memberCounts[group.id] = usersResponse.users.length;
        } catch (e) {
          // Nếu không lấy được số thành viên, để 0
          memberCounts[group.id] = 0;
        }
      }

      if (mounted) {
        setState(() {
          _groups = groups;
          _memberCounts = memberCounts;
          _isLoading = false;
        });
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

    if (_groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Chưa có nhóm nào',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          final memberCount = _memberCounts[group.id] ?? 0;
          return _buildGroupCard(
            context: context,
            name: group.name,
            memberCount: memberCount,
            groupId: group.id,
          );
        },
      ),
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
