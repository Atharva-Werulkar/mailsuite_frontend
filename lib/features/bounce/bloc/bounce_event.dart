/// Bounce Events
abstract class BounceEvent {}

/// Load bounces with optional filters
class LoadBouncesEvent extends BounceEvent {
  final String? mailboxId;
  final int limit;
  final int offset;
  final bool isRefresh;

  LoadBouncesEvent({
    this.mailboxId,
    this.limit = 50,
    this.offset = 0,
    this.isRefresh = false,
  });
}

/// Load more bounces (pagination)
class LoadMoreBouncesEvent extends BounceEvent {}

/// Refresh bounces
class RefreshBouncesEvent extends BounceEvent {
  final String? mailboxId;

  RefreshBouncesEvent({this.mailboxId});
}

/// Load bounce statistics
class LoadBounceStatsEvent extends BounceEvent {}

/// Load unique count
class LoadUniqueCountEvent extends BounceEvent {
  final String? mailboxId;

  LoadUniqueCountEvent({this.mailboxId});
}
