import 'api_service.dart';
import '../utils/app_logger.dart';

/// Model for user search result
class UserSearchResult {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  UserSearchResult({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    // Backend returns:
    // - id: social_logins.id (not needed for calendar lookup)
    // - user_id: users.id (needed for calendar connection lookup)
    // We must use user_id because GetConnectionsByUserIDs queries by user_id
    final userId = json['user_id']?.toString() ?? json['id']?.toString() ?? '';
    
    AppLogger.info('UserSearchResult: Using user_id=$userId', tag: 'UserSearchResult');
    
    return UserSearchResult(
      id: userId,
      email: json['email'] ?? json['provider_email'] ?? '',
      displayName: json['display_name'] ?? json['provider_username'] ?? json['username'],
      avatarUrl: json['avatar_url'] ?? json['photo_url'],
    );
  }

  String get displayText => displayName ?? email;
  
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }
}

/// Service for searching users
class UserSearchService {
  static const String _tag = 'UserSearchService';

  /// Search users by email or name
  /// GET /api/v1/private/auth/users/search?q=keyword
  static Future<List<UserSearchResult>> searchUsers(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }

    try {
      AppLogger.info('Searching users: $query', tag: _tag);
      
      final response = await ApiService.get(
        '/api/v1/private/auth/users/search?q=${Uri.encodeComponent(query)}',
      );

      if (response['status'] == 200 && response['data'] != null) {
        final List<dynamic> usersData = response['data'] as List<dynamic>? ?? [];
        
        // Log để debug cấu trúc response
        AppLogger.info('UserSearchService: Found ${usersData.length} users', tag: _tag);
        if (usersData.isNotEmpty) {
          final firstUser = usersData.first as Map<String, dynamic>;
          AppLogger.info('UserSearchService: First user keys: ${firstUser.keys.toList()}', tag: _tag);
          AppLogger.info('UserSearchService: First user FULL data: $firstUser', tag: _tag);
          // Log các field quan trọng
          AppLogger.info('UserSearchService: id=${firstUser['id']}, social_login_id=${firstUser['social_login_id']}, social_login=${firstUser['social_login']}', tag: _tag);
        }
        
        final results = usersData
            .map((u) => UserSearchResult.fromJson(u as Map<String, dynamic>))
            .toList();
        
        // Log kết quả sau khi parse
        if (results.isNotEmpty) {
          AppLogger.info('UserSearchService: Parsed first result ID: ${results.first.id}', tag: _tag);
        }
        
        return results;
      }
      
      return [];
    } catch (e) {
      AppLogger.error('Failed to search users', tag: _tag, error: e);
      return [];
    }
  }

  /// Get all users (for small user base)
  /// GET /api/v1/private/auth/users/social
  static Future<List<UserSearchResult>> getAllUsers() async {
    try {
      AppLogger.info('Getting all users', tag: _tag);
      
      final response = await ApiService.get('/api/v1/private/auth/users/social');

      if (response['status'] == 200 && response['data'] != null) {
        final data = response['data'];
        List<dynamic> usersData;
        
        if (data is Map && data['items'] != null) {
          usersData = data['items'] as List<dynamic>;
        } else if (data is List) {
          usersData = data;
        } else {
          return [];
        }
        
        return usersData
            .map((u) => UserSearchResult.fromJson(u as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      AppLogger.error('Failed to get users', tag: _tag, error: e);
      return [];
    }
  }
}
