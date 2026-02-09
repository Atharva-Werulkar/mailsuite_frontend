import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/thread_service.dart';
import 'thread_event.dart';
import 'thread_state.dart';

/// Thread BLoC - Business Logic Component for Threads
class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  final ThreadService _threadService;

  // Keep track of current filters for pagination
  bool? _currentIsUnread;
  bool? _currentIsArchived;
  int _currentLimit = 50;

  ThreadBloc(this._threadService) : super(ThreadInitial()) {
    on<LoadThreadsEvent>(_onLoadThreads);
    on<LoadMoreThreadsEvent>(_onLoadMoreThreads);
    on<RefreshThreadsEvent>(_onRefreshThreads);
    on<LoadThreadDetailEvent>(_onLoadThreadDetail);
    on<LoadThreadStatsEvent>(_onLoadThreadStats);
    on<MarkThreadAsReadEvent>(_onMarkThreadAsRead);
    on<ToggleThreadArchiveEvent>(_onToggleThreadArchive);
    on<DeleteThreadEvent>(_onDeleteThread);
  }

  /// Load threads with filters
  Future<void> _onLoadThreads(
    LoadThreadsEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        // Keep current data visible while refreshing
        if (state is! ThreadLoaded) {
          emit(ThreadLoading());
        }
      } else {
        emit(ThreadLoading());
      }

      // Store current filters
      _currentIsUnread = event.isUnread;
      _currentIsArchived = event.isArchived;
      _currentLimit = event.limit;

      final response = await _threadService.fetchThreads(
        isUnread: event.isUnread,
        isArchived: event.isArchived,
        limit: event.limit,
        offset: event.offset,
      );

      if (response.data.isEmpty) {
        emit(ThreadEmpty());
      } else {
        final hasMore = response.data.length >= event.limit;
        emit(
          ThreadLoaded(
            threads: response.data,
            total: response.total,
            hasMore: hasMore,
            currentOffset: event.offset,
          ),
        );
      }
    } catch (e) {
      log('❌ [ThreadBloc] Error loading threads: $e', error: e);
      emit(ThreadError(e.toString()));
    }
  }

  /// Load more threads (pagination)
  Future<void> _onLoadMoreThreads(
    LoadMoreThreadsEvent event,
    Emitter<ThreadState> emit,
  ) async {
    if (state is! ThreadLoaded) return;

    final currentState = state as ThreadLoaded;
    if (!currentState.hasMore) return;

    try {
      emit(
        ThreadLoadingMore(
          currentThreads: currentState.threads,
          currentOffset: currentState.currentOffset,
        ),
      );

      final newOffset = currentState.currentOffset + _currentLimit;

      final response = await _threadService.fetchThreads(
        isUnread: _currentIsUnread,
        isArchived: _currentIsArchived,
        limit: _currentLimit,
        offset: newOffset,
      );

      final updatedThreads = [...currentState.threads, ...response.data];
      final hasMore = response.data.length >= _currentLimit;

      emit(
        ThreadLoaded(
          threads: updatedThreads,
          total: response.total,
          hasMore: hasMore,
          currentOffset: newOffset,
          stats: currentState.stats,
        ),
      );
    } catch (e) {
      log('❌ [ThreadBloc] Error loading more threads: $e', error: e);
      emit(ThreadError(e.toString()));
    }
  }

  /// Refresh threads
  Future<void> _onRefreshThreads(
    RefreshThreadsEvent event,
    Emitter<ThreadState> emit,
  ) async {
    add(
      LoadThreadsEvent(
        isUnread: _currentIsUnread,
        isArchived: _currentIsArchived,
        isRefresh: true,
      ),
    );
  }

  /// Load single thread detail
  Future<void> _onLoadThreadDetail(
    LoadThreadDetailEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      emit(ThreadLoading());

      final thread = await _threadService.getThread(event.threadId);

      emit(ThreadDetailLoaded(thread));
    } catch (e) {
      log('❌ [ThreadBloc] Error loading thread detail: $e', error: e);
      emit(ThreadError(e.toString()));
    }
  }

  /// Load thread statistics
  Future<void> _onLoadThreadStats(
    LoadThreadStatsEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      final stats = await _threadService.getStats();

      if (state is ThreadLoaded) {
        emit((state as ThreadLoaded).copyWith(stats: stats));
      } else {
        emit(ThreadStatsLoaded(stats));
      }
    } catch (e) {
      log('❌ [ThreadBloc] Error loading thread stats: $e', error: e);
      // Don't emit error state, just log it
    }
  }

  /// Mark thread as read/unread
  Future<void> _onMarkThreadAsRead(
    MarkThreadAsReadEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      final updatedThread = await _threadService.markAsRead(
        event.threadId,
        event.isRead,
      );

      // Update the thread in current list if loaded
      if (state is ThreadLoaded) {
        final currentState = state as ThreadLoaded;
        final updatedThreads = currentState.threads.map((thread) {
          return thread.id == event.threadId ? updatedThread : thread;
        }).toList();

        emit(currentState.copyWith(threads: updatedThreads));
      } else if (state is ThreadDetailLoaded) {
        emit(ThreadDetailLoaded(updatedThread));
      }

      emit(
        ThreadUpdated(
          thread: updatedThread,
          message: event.isRead ? 'Marked as read' : 'Marked as unread',
        ),
      );
    } catch (e) {
      log('❌ [ThreadBloc] Error marking thread as read: $e', error: e);
      emit(ThreadError(e.toString()));
    }
  }

  /// Toggle thread archive
  Future<void> _onToggleThreadArchive(
    ToggleThreadArchiveEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      final updatedThread = await _threadService.toggleArchive(
        event.threadId,
        event.isArchived,
      );

      // Remove from list if archived
      if (state is ThreadLoaded && event.isArchived) {
        final currentState = state as ThreadLoaded;
        final updatedThreads = currentState.threads
            .where((thread) => thread.id != event.threadId)
            .toList();

        emit(currentState.copyWith(threads: updatedThreads));
      } else if (state is ThreadDetailLoaded) {
        emit(ThreadDetailLoaded(updatedThread));
      }

      emit(
        ThreadUpdated(
          thread: updatedThread,
          message: event.isArchived ? 'Archived' : 'Unarchived',
        ),
      );
    } catch (e) {
      log('❌ [ThreadBloc] Error toggling archive: $e', error: e);
      emit(ThreadError(e.toString()));
    }
  }

  /// Delete thread
  Future<void> _onDeleteThread(
    DeleteThreadEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      await _threadService.deleteThread(event.threadId);

      // Remove from list if loaded
      if (state is ThreadLoaded) {
        final currentState = state as ThreadLoaded;
        final updatedThreads = currentState.threads
            .where((thread) => thread.id != event.threadId)
            .toList();

        emit(currentState.copyWith(threads: updatedThreads));
      }

      emit(ThreadDeleted(threadId: event.threadId, message: 'Thread deleted'));
    } catch (e) {
      log('❌ [ThreadBloc] Error deleting thread: $e', error: e);
      emit(ThreadError(e.toString()));
    }
  }
}
