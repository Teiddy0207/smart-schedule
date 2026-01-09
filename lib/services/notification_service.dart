import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/invitation_data.dart';

class NotificationService {
  /// Get pending invitations for current user
  static Future<List<InvitationData>> getPendingInvitations() async {
    try {
      debugPrint('Calling ApiService.get(/api/v1/private/invitations)');
      final response = await ApiService.get('/api/v1/private/invitations');
      debugPrint('ApiService response: $response');

      List<dynamic> invitations = [];
      
      // Handle different response structures
      if (response['invitations'] != null) {
        invitations = response['invitations'] as List<dynamic>;
      } else if (response['data'] != null && response['data']['invitations'] != null) {
        invitations = response['data']['invitations'] as List<dynamic>;
      }

      return invitations
          .map((json) => InvitationData.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to get pending invitations: $e');
      return [];
    }
  }

  /// Get count of pending invitations
  static Future<int> getPendingCount() async {
    try {
      final response = await ApiService.get('/api/v1/private/invitations/count');
      
      if (response['count'] != null) {
        return response['count'] as int? ?? 0;
      } else if (response['data'] != null && response['data']['count'] != null) {
        return response['data']['count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Failed to get pending count: $e');
      return 0;
    }
  }

  /// Accept an invitation
  static Future<void> acceptInvitation(String invitationId) async {
    debugPrint('Accepting invitation: $invitationId');
    await ApiService.post('/api/v1/private/invitations/$invitationId/accept');
  }

  /// Decline an invitation
  static Future<void> declineInvitation(String invitationId) async {
    debugPrint('Declining invitation: $invitationId');
    await ApiService.post('/api/v1/private/invitations/$invitationId/decline');
  }
}
