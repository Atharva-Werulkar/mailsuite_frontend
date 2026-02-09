import 'dart:developer';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/email_model.dart';

/// Email Service - Handles email-related API calls
class EmailService {
  final ApiClient _apiClient;

  EmailService(this._apiClient);

  /// Fetch emails with filters and pagination
  Future<EmailListResponse> fetchEmails({
    String? category,
    String? mailboxId,
    String? threadId,
    String? search,
    bool? isRead,
    bool? isStarred,
    bool? isArchived,
    int limit = 50,
    int offset = 0,
  }) async {
    log(
      '🌐 [EmailService] Fetching emails - category: $category, limit: $limit, offset: $offset',
    );

    try {
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        'category': ?category,
        'mailbox_id': ?mailboxId,
        'thread_id': ?threadId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (isRead != null) 'is_read': isRead.toString(),
        if (isStarred != null) 'is_starred': isStarred.toString(),
        if (isArchived != null) 'is_archived': isArchived.toString(),
      };

      log(
        '📡 [EmailService] API Request: GET ${ApiConstants.emails} with params: $queryParams',
      );
      final response = await _apiClient.get(
        ApiConstants.emails,
        queryParameters: queryParams,
      );

      final result = EmailListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      log('✅ [EmailService] Successfully fetched ${result.data.length} emails');

      return result;
    } catch (e) {
      log('❌ [EmailService] Error fetching emails: $e', error: e);
      rethrow;
    }
  }

  /// Get single email by ID
  Future<EmailModel> getEmail(String emailId) async {
    log('🌐 [EmailService] Fetching email - id: $emailId');

    try {
      log('📡 [EmailService] API Request: GET ${ApiConstants.emails}/$emailId');
      final response = await _apiClient.get('${ApiConstants.emails}/$emailId');

      final result = EmailModel.fromJson(response.data as Map<String, dynamic>);
      log('✅ [EmailService] Successfully fetched email');

      return result;
    } catch (e) {
      log('❌ [EmailService] Error fetching email: $e', error: e);
      rethrow;
    }
  }

  /// Get category counts
  Future<CategoryCountsResponse> getCategoryCounts() async {
    log('🌐 [EmailService] Fetching category counts');

    try {
      log(
        '📡 [EmailService] API Request: GET ${ApiConstants.emailsCategories}',
      );
      final response = await _apiClient.get(ApiConstants.emailsCategories);

      final result = CategoryCountsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      log('✅ [EmailService] Successfully fetched category counts');

      return result;
    } catch (e) {
      log('❌ [EmailService] Error fetching category counts: $e', error: e);
      rethrow;
    }
  }

  /// Mark email as read/unread
  Future<EmailModel> markAsRead(String emailId, bool isRead) async {
    log(
      '🌐 [EmailService] Marking email as ${isRead ? "read" : "unread"} - id: $emailId',
    );

    try {
      log(
        '📡 [EmailService] API Request: PUT ${ApiConstants.emails}/$emailId/read',
      );
      final response = await _apiClient.put(
        '${ApiConstants.emails}/$emailId/read',
        data: {'is_read': isRead},
      );

      final result = EmailModel.fromJson(response.data as Map<String, dynamic>);
      log('✅ [EmailService] Successfully updated email read status');

      return result;
    } catch (e) {
      log('❌ [EmailService] Error updating read status: $e', error: e);
      rethrow;
    }
  }

  /// Star/unstar email
  Future<EmailModel> toggleStar(String emailId, bool isStarred) async {
    log(
      '🌐 [EmailService] ${isStarred ? "Starring" : "Unstarring"} email - id: $emailId',
    );

    try {
      log(
        '📡 [EmailService] API Request: PUT ${ApiConstants.emails}/$emailId/star',
      );
      final response = await _apiClient.put(
        '${ApiConstants.emails}/$emailId/star',
        data: {'is_starred': isStarred},
      );

      final result = EmailModel.fromJson(response.data as Map<String, dynamic>);
      log('✅ [EmailService] Successfully updated email star status');

      return result;
    } catch (e) {
      log('❌ [EmailService] Error updating star status: $e', error: e);
      rethrow;
    }
  }

  /// Archive/unarchive email
  Future<EmailModel> toggleArchive(String emailId, bool isArchived) async {
    log(
      '🌐 [EmailService] ${isArchived ? "Archiving" : "Unarchiving"} email - id: $emailId',
    );

    try {
      log(
        '📡 [EmailService] API Request: PUT ${ApiConstants.emails}/$emailId/archive',
      );
      final response = await _apiClient.put(
        '${ApiConstants.emails}/$emailId/archive',
        data: {'is_archived': isArchived},
      );

      final result = EmailModel.fromJson(response.data as Map<String, dynamic>);
      log('✅ [EmailService] Successfully updated email archive status');

      return result;
    } catch (e) {
      log('❌ [EmailService] Error updating archive status: $e', error: e);
      rethrow;
    }
  }

  /// Delete email
  Future<void> deleteEmail(String emailId) async {
    log('🌐 [EmailService] Deleting email - id: $emailId');

    try {
      log(
        '📡 [EmailService] API Request: DELETE ${ApiConstants.emails}/$emailId',
      );
      await _apiClient.delete('${ApiConstants.emails}/$emailId');
      log('✅ [EmailService] Successfully deleted email');
    } catch (e) {
      log('❌ [EmailService] Error deleting email: $e', error: e);
      rethrow;
    }
  }
}
