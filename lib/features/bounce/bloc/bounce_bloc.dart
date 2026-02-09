import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/bounce_service.dart';
import 'bounce_event.dart';
import 'bounce_state.dart';

/// Bounce BLoC - Manages bounce-related state
class BounceBloc extends Bloc<BounceEvent, BounceState> {
  final BounceService _bounceService;

  BounceBloc(this._bounceService) : super(BounceInitial()) {
    on<LoadBouncesEvent>(_onLoadBounces);
    on<LoadMoreBouncesEvent>(_onLoadMoreBounces);
    on<RefreshBouncesEvent>(_onRefreshBounces);
    on<LoadBounceStatsEvent>(_onLoadBounceStats);
    on<LoadUniqueCountEvent>(_onLoadUniqueCount);
  }

  /// Extract clean error message from exception
  String _extractErrorMessage(dynamic error) {
    final errorString = error.toString();
    log('🔍 [BounceBloc] Extracting error from: $errorString');
    
    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      final cleaned = errorString.substring('Exception: '.length);
      log('✂️ [BounceBloc] Cleaned error message: $cleaned');
      return cleaned;
    }
    
    return errorString;
  }

  /// Handle Load Bounces Event
  Future<void> _onLoadBounces(
    LoadBouncesEvent event,
    Emitter<BounceState> emit,
  ) async {
    log('📥 [BounceBloc] LoadBouncesEvent received - mailboxId: ${event.mailboxId}, limit: ${event.limit}, offset: ${event.offset}');
    
    try {
      if (event.isRefresh && state is BounceLoaded) {
        log('🔄 [BounceBloc] Refresh mode - skipping loading state');
      } else {
        log('⏳ [BounceBloc] Emitting BounceLoading state');
        emit(BounceLoading());
      }

      final response = await _bounceService.fetchBounces(
        mailboxId: event.mailboxId,
        limit: event.limit,
        offset: event.offset,
      );

      log('✅ [BounceBloc] Bounces loaded successfully - count: ${response.data.length}, total: ${response.total}');
      emit(BounceLoaded(
        bounces: response.data,
        total: response.total,
        hasMore: response.data.length >= event.limit,
        currentOffset: event.offset,
      ));
    } catch (e) {
      log('❌ [BounceBloc] Error loading bounces: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [BounceBloc] User-facing error: $errorMessage');
      emit(BounceError(errorMessage));
    }
  }

  /// Handle Load More Bounces Event (Pagination)
  Future<void> _onLoadMoreBounces(
    LoadMoreBouncesEvent event,
    Emitter<BounceState> emit,
  ) async {
    log('📄 [BounceBloc] LoadMoreBouncesEvent received');
    
    if (state is! BounceLoaded) {
      log('⚠️ [BounceBloc] Cannot load more - current state is not BounceLoaded');
      return;
    }

    final currentState = state as BounceLoaded;
    if (!currentState.hasMore) {
      log('⚠️ [BounceBloc] Cannot load more - no more bounces available');
      return;
    }

    try {
      log('⏳ [BounceBloc] Loading more bounces - current count: ${currentState.bounces.length}');
      emit(BounceLoadingMore(
        currentBounces: currentState.bounces,
        total: currentState.total,
      ));

      final newOffset = currentState.currentOffset + 50;
      log('🔍 [BounceBloc] Fetching bounces with offset: $newOffset');
      
      final response = await _bounceService.fetchBounces(
        limit: 50,
        offset: newOffset,
      );

      log('✅ [BounceBloc] More bounces loaded - new count: ${response.data.length}, total bounces: ${currentState.bounces.length + response.data.length}');
      emit(BounceLoaded(
        bounces: [...currentState.bounces, ...response.data],
        total: response.total,
        hasMore: response.data.length >= 50,
        currentOffset: newOffset,
      ));
    } catch (e) {
      log('❌ [BounceBloc] Error loading more bounces: $e', error: e);
      emit(BounceError(e.toString()));
    }
  }

  /// Handle Refresh Bounces Event
  Future<void> _onRefreshBounces(
    RefreshBouncesEvent event,
    Emitter<BounceState> emit,
  ) async {
    log('🔄 [BounceBloc] RefreshBouncesEvent received - mailboxId: ${event.mailboxId}');
    add(LoadBouncesEvent(
      mailboxId: event.mailboxId,
      isRefresh: true,
    ));
  }

  /// Handle Load Bounce Stats Event
  Future<void> _onLoadBounceStats(
    LoadBounceStatsEvent event,
    Emitter<BounceState> emit,
  ) async {
    log('📊 [BounceBloc] LoadBounceStatsEvent received');
    
    try {
      log('⏳ [BounceBloc] Loading bounce statistics...');
      emit(BounceLoading());
      
      final stats = await _bounceService.getStats();
      log('✅ [BounceBloc] Bounce stats loaded successfully');
      
      emit(BounceStatsLoaded(stats));
    } catch (e) {
      log('❌ [BounceBloc] Error loading bounce stats: $e', error: e);
      emit(BounceError(e.toString()));
    }
  }

  /// Handle Load Unique Count Event
  Future<void> _onLoadUniqueCount(
    LoadUniqueCountEvent event,
    Emitter<BounceState> emit,
  ) async {
    try {
      final uniqueCount = await _bounceService.getUniqueCount(
        mailboxId: event.mailboxId,
      );
      emit(UniqueCountLoaded(uniqueCount));
    } catch (e) {
      emit(BounceError(e.toString()));
    }
  }
}
