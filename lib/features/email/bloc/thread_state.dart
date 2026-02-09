import 'package:equatable/equatable.dart';

import '../models/thread_model.dart';

/// Thread States
abstract class ThreadState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial State
class ThreadInitial extends ThreadState {}

/// Loading State
class ThreadLoading extends ThreadState {}

/// Loaded State
class ThreadLoaded extends ThreadState {
  final List<EmailThreadModel> threads;
  final int total;
  final bool hasMore;
  final int currentOffset;
  final ThreadStatsResponse? stats;

  ThreadLoaded({
    required this.threads,
    required this.total,
    required this.hasMore,
    required this.currentOffset,
    this.stats,
  });

  @override
  List<Object?> get props => [threads, total, hasMore, currentOffset, stats];

  ThreadLoaded copyWith({
    List<EmailThreadModel>? threads,
    int? total,
    bool? hasMore,
    int? currentOffset,
    ThreadStatsResponse? stats,
  }) {
    return ThreadLoaded(
      threads: threads ?? this.threads,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      stats: stats ?? this.stats,
    );
  }
}

/// Loading More State (for pagination)
class ThreadLoadingMore extends ThreadState {
  final List<EmailThreadModel> currentThreads;
  final int currentOffset;

  ThreadLoadingMore({
    required this.currentThreads,
    required this.currentOffset,
  });

  @override
  List<Object?> get props => [currentThreads, currentOffset];
}

/// Thread Detail Loaded
class ThreadDetailLoaded extends ThreadState {
  final EmailThreadModel thread;

  ThreadDetailLoaded(this.thread);

  @override
  List<Object?> get props => [thread];
}

/// Thread Updated (after marking read, archive)
class ThreadUpdated extends ThreadState {
  final EmailThreadModel thread;
  final String message;

  ThreadUpdated({required this.thread, required this.message});

  @override
  List<Object?> get props => [thread, message];
}

/// Thread Deleted
class ThreadDeleted extends ThreadState {
  final String threadId;
  final String message;

  ThreadDeleted({required this.threadId, required this.message});

  @override
  List<Object?> get props => [threadId, message];
}

/// Thread Stats Loaded
class ThreadStatsLoaded extends ThreadState {
  final ThreadStatsResponse stats;

  ThreadStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Error State
class ThreadError extends ThreadState {
  final String message;

  ThreadError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty State
class ThreadEmpty extends ThreadState {
  final String message;

  ThreadEmpty({this.message = 'No threads found'});

  @override
  List<Object?> get props => [message];
}
