import 'dart:developer';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/mailbox_model.dart';

/// Mailbox Service - Handles mailbox-related API calls
class MailboxService {
  final ApiClient _apiClient;

  MailboxService(this._apiClient);

  /// Fetch all mailboxes for the current user
  Future<List<MailboxModel>> fetchMailboxes() async {
    log('🌐 [MailboxService] Fetching mailboxes');

    try {
      log('📡 [MailboxService] API Request: GET ${ApiConstants.mailboxes}');
      final response = await _apiClient.get(ApiConstants.mailboxes);

      // Backend returns {"data": [...]}
      final responseData = response.data as Map<String, dynamic>;
      final List<dynamic> data = responseData['data'] as List<dynamic>;

      final mailboxes = data
          .map((item) => MailboxModel.fromJson(item as Map<String, dynamic>))
          .toList();

      log(
        '✅ [MailboxService] Successfully fetched ${mailboxes.length} mailboxes',
      );
      return mailboxes;
    } catch (e) {
      log('❌ [MailboxService] Error fetching mailboxes: $e', error: e);
      rethrow; // Preserve original error message
    }
  }

  /// Add a new mailbox
  Future<MailboxModel> addMailbox(MailboxCreateRequest request) async {
    log('🌐 [MailboxService] Adding mailbox - email: ${request.emailAddress}');

    try {
      log('📡 [MailboxService] API Request: POST ${ApiConstants.mailboxes}');
      final response = await _apiClient.post(
        ApiConstants.mailboxes,
        data: request.toJson(),
      );

      // Backend returns {"data": {...}}
      final responseData = response.data as Map<String, dynamic>;
      final mailbox = MailboxModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
      log('✅ [MailboxService] Mailbox added successfully - id: ${mailbox.id}');

      return mailbox;
    } catch (e) {
      log('❌ [MailboxService] Error adding mailbox: $e', error: e);
      rethrow; // Preserve original error message
    }
  }

  /// Test IMAP connection
  Future<bool> testConnection({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    log(
      '🌐 [MailboxService] Testing IMAP connection - host: $host:$port, user: $username',
    );

    try {
      log(
        '📡 [MailboxService] API Request: POST ${ApiConstants.mailboxes}/test-connection',
      );
      final response = await _apiClient.post(
        '${ApiConstants.mailboxes}/test',
        data: {
          'imap_host': host,
          'imap_port': port,
          'imap_username': username,
          'imap_password': password,
        },
      );

      final success = response.data['success'] == true;
      log(
        success
            ? '✅ [MailboxService] Connection test successful'
            : '⚠️ [MailboxService] Connection test failed',
      );

      return success;
    } catch (e) {
      log('❌ [MailboxService] Error testing connection: $e', error: e);
      rethrow; // Preserve original error message
    }
  }

  /// Update mailbox
  Future<MailboxModel> updateMailbox(
    String mailboxId,
    Map<String, dynamic> updates,
  ) async {
    log('🌐 [MailboxService] Updating mailbox - id: $mailboxId');

    try {
      log(
        '📡 [MailboxService] API Request: PUT ${ApiConstants.mailboxes}/$mailboxId',
      );
      final response = await _apiClient.put(
        '${ApiConstants.mailboxes}/$mailboxId',
        data: updates,
      );

      // Backend returns {"data": {...}}
      final responseData = response.data as Map<String, dynamic>;
      final mailbox = MailboxModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
      log('✅ [MailboxService] Mailbox updated successfully');

      return mailbox;
    } catch (e) {
      log('❌ [MailboxService] Error updating mailbox: $e', error: e);
      rethrow; // Preserve original error message
    }
  }

  /// Delete mailbox
  Future<void> deleteMailbox(String mailboxId) async {
    log('🌐 [MailboxService] Deleting mailbox - id: $mailboxId');

    try {
      log(
        '📡 [MailboxService] API Request: DELETE ${ApiConstants.mailboxes}/$mailboxId',
      );
      await _apiClient.delete('${ApiConstants.mailboxes}/$mailboxId');

      log('✅ [MailboxService] Mailbox deleted successfully');
    } catch (e) {
      log('❌ [MailboxService] Error deleting mailbox: $e', error: e);
      rethrow; // Preserve original error message
    }
  }
}
