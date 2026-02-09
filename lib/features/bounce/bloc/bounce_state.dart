import 'package:equatable/equatable.dart';
import '../models/bounce_model.dart';

/// Bounce States
abstract class BounceState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial State
class BounceInitial extends BounceState {}

/// Loading State
class BounceLoading extends BounceState {}

/// Loaded State
class BounceLoaded extends BounceState {
  final List<BounceModel> bounces;
  final int total;
  final bool hasMore;
  final int currentOffset;

  BounceLoaded({
    required this.bounces,
    required this.total,
    required this.hasMore,
    required this.currentOffset,
  });

  @override
  List<Object?> get props => [bounces, total, hasMore, currentOffset];

  BounceLoaded copyWith({
    List<BounceModel>? bounces,
    int? total,
    bool? hasMore,
    int? currentOffset,
  }) {
    return BounceLoaded(
      bounces: bounces ?? this.bounces,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

/// Loading More State (for pagination)
class BounceLoadingMore extends BounceState {
  final List<BounceModel> currentBounces;
  final int total;

  BounceLoadingMore({
    required this.currentBounces,
    required this.total,
  });

  @override
  List<Object?> get props => [currentBounces, total];
}

/// Error State
class BounceError extends BounceState {
  final String message;

  BounceError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Stats Loaded State
class BounceStatsLoaded extends BounceState {
  final BounceStatsResponse stats;

  BounceStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Unique Count Loaded State
class UniqueCountLoaded extends BounceState {
  final UniqueCountResponse uniqueCount;

  UniqueCountLoaded(this.uniqueCount);

  @override
  List<Object?> get props => [uniqueCount];
}
