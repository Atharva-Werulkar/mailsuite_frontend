import 'dart:developer';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/bounce_model.dart';

/// Bounce Service - Handles bounce-related API calls
class BounceService {
  final ApiClient _apiClient;

  BounceService(this._apiClient);

  /// Fetch bounces with pagination
  Future<BounceListResponse> fetchBounces({
    String? mailboxId,
    int limit = 50,
    int offset = 0,
  }) async {
    log(
      '🌐 [BounceService] Fetching bounces - mailboxId: $mailboxId, limit: $limit, offset: $offset',
    );

    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'mailbox_id': ?mailboxId,
      };

      log(
        '📡 [BounceService] API Request: GET ${ApiConstants.bounces} with params: $queryParams',
      );
      final response = await _apiClient.get(
        ApiConstants.bounces,
        queryParameters: queryParams,
      );

      final result = BounceListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      log(
        '✅ [BounceService] Successfully fetched ${result.data.length} bounces',
      );

      return result;
    } catch (e) {
      log('❌ [BounceService] Error fetching bounces: $e', error: e);
      rethrow; // Preserve original error message
    }
  }

  /// Get unique failed emails count
  Future<UniqueCountResponse> getUniqueCount({String? mailboxId}) async {
    log('🌐 [BounceService] Fetching unique count - mailboxId: $mailboxId');

    try {
      final queryParams = {'mailbox_id': ?mailboxId};

      log('📡 [BounceService] API Request: GET ${ApiConstants.bouncesUnique}');
      final response = await _apiClient.get(
        ApiConstants.bouncesUnique,
        queryParameters: queryParams,
      );

      final result = UniqueCountResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      log('✅ [BounceService] Unique count fetched - total: ${result.total}');

      return result;
    } catch (e) {
      log('❌ [BounceService] Error fetching unique count: $e', error: e);
      rethrow; // Preserve original error message
    }
  }

  /// Get bounce statistics
  Future<BounceStatsResponse> getStats() async {
    log('🌐 [BounceService] Fetching bounce statistics');

    try {
      log('📡 [BounceService] API Request: GET ${ApiConstants.bouncesStats}');
      final response = await _apiClient.get(ApiConstants.bouncesStats);

      final result = BounceStatsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      log('✅ [BounceService] Stats fetched successfully');

      return result;
    } catch (e) {
      log('❌ [BounceService] Error fetching stats: $e', error: e);
      rethrow; // Preserve original error message
    }
  }
}
