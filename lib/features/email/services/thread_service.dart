import 'dart:developer';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/thread_model.dart';

/// Thread Service - Handles thread-related API calls
class ThreadService {
  final ApiClient _apiClient;

  ThreadService(this._apiClient);

  /// Fetch threads with filters and pagination
  Future<ThreadListResponse> fetchThreads({
    bool? isUnread,
    bool? isArchived,
    int limit = 50,
    int offset = 0,
  }) async {
    log('🌐 [ThreadService] Fetching threads - limit: $limit, offset: $offset');

    try {
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (isUnread != null) 'is_unread': isUnread.toString(),
        if (isArchived != null) 'is_archived': isArchived.toString(),
      };

      log(
        '📡 [ThreadService] API Request: GET ${ApiConstants.threads} with params: $queryParams',
      );
      final response = await _apiClient.get(
        ApiConstants.threads,
        queryParameters: queryParams,
      );

      final result = ThreadListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      log(
        '✅ [ThreadService] Successfully fetched ${result.data.length} threads',
      );

      return result;
    } catch (e) {
      log('❌ [ThreadService] Error fetching threads: $e', error: e);
      rethrow;
    }
  }

  /// Get single thread with all messages
  Future<EmailThreadModel> getThread(String threadId) async {
    log('🌐 [ThreadService] Fetching thread - id: $threadId');

    try {
      log(
        '📡 [ThreadService] API Request: GET ${ApiConstants.threads}/$threadId',
      );
      final response = await _apiClient.get(
        '${ApiConstants.threads}/$threadId',
      );

      final result = EmailThreadModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      log(
        '✅ [ThreadService] Successfully fetched thread with ${result.messages?.length ?? 0} messages',
      );

      return result;
    } catch (e) {
      log('❌ [ThreadService] Error fetching thread: $e', error: e);
      rethrow;
    }
  }

  /// Get thread statistics
  Future<ThreadStatsResponse> getStats() async {
    log('🌐 [ThreadService] Fetching thread statistics');

    try {
      log('📡 [ThreadService] API Request: GET ${ApiConstants.threadsStats}');
      final response = await _apiClient.get(ApiConstants.threadsStats);

      final result = ThreadStatsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      log('✅ [ThreadService] Successfully fetched thread stats');

      return result;
    } catch (e) {
      log('❌ [ThreadService] Error fetching thread stats: $e', error: e);
      rethrow;
    }
  }

  /// Mark thread as read/unread
  Future<EmailThreadModel> markAsRead(String threadId, bool isRead) async {
    log(
      '🌐 [ThreadService] Marking thread as ${isRead ? "read" : "unread"} - id: $threadId',
    );

    try {
      log(
        '📡 [ThreadService] API Request: PUT ${ApiConstants.threads}/$threadId/read',
      );
      final response = await _apiClient.put(
        '${ApiConstants.threads}/$threadId/read',
        data: {'is_read': isRead},
      );

      final result = EmailThreadModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      log('✅ [ThreadService] Successfully updated thread read status');

      return result;
    } catch (e) {
      log('❌ [ThreadService] Error updating thread read status: $e', error: e);
      rethrow;
    }
  }

  /// Archive/unarchive thread
  Future<EmailThreadModel> toggleArchive(
    String threadId,
    bool isArchived,
  ) async {
    log(
      '🌐 [ThreadService] ${isArchived ? "Archiving" : "Unarchiving"} thread - id: $threadId',
    );

    try {
      log(
        '📡 [ThreadService] API Request: PUT ${ApiConstants.threads}/$threadId/archive',
      );
      final response = await _apiClient.put(
        '${ApiConstants.threads}/$threadId/archive',
        data: {'is_archived': isArchived},
      );

      final result = EmailThreadModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      log('✅ [ThreadService] Successfully updated thread archive status');

      return result;
    } catch (e) {
      log(
        '❌ [ThreadService] Error updating thread archive status: $e',
        error: e,
      );
      rethrow;
    }
  }

  /// Delete thread and all messages
  Future<void> deleteThread(String threadId) async {
    log('🌐 [ThreadService] Deleting thread - id: $threadId');

    try {
      log(
        '📡 [ThreadService] API Request: DELETE ${ApiConstants.threads}/$threadId',
      );
      await _apiClient.delete('${ApiConstants.threads}/$threadId');
      log('✅ [ThreadService] Successfully deleted thread');
    } catch (e) {
      log('❌ [ThreadService] Error deleting thread: $e', error: e);
      rethrow;
    }
  }
}
