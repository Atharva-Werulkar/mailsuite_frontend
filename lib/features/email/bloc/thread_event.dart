/// Thread Events
abstract class ThreadEvent {}

/// Load threads with filters
class LoadThreadsEvent extends ThreadEvent {
  final bool? isUnread;
  final bool? isArchived;
  final int limit;
  final int offset;
  final bool isRefresh;

  LoadThreadsEvent({
    this.isUnread,
    this.isArchived,
    this.limit = 50,
    this.offset = 0,
    this.isRefresh = false,
  });
}

/// Load more threads (pagination)
class LoadMoreThreadsEvent extends ThreadEvent {}

/// Refresh threads
class RefreshThreadsEvent extends ThreadEvent {}

/// Load single thread with all messages
class LoadThreadDetailEvent extends ThreadEvent {
  final String threadId;

  LoadThreadDetailEvent(this.threadId);
}

/// Load thread statistics
class LoadThreadStatsEvent extends ThreadEvent {}

/// Mark thread as read/unread
class MarkThreadAsReadEvent extends ThreadEvent {
  final String threadId;
  final bool isRead;

  MarkThreadAsReadEvent({required this.threadId, required this.isRead});
}

/// Toggle thread archive
class ToggleThreadArchiveEvent extends ThreadEvent {
  final String threadId;
  final bool isArchived;

  ToggleThreadArchiveEvent({required this.threadId, required this.isArchived});
}

/// Delete thread
class DeleteThreadEvent extends ThreadEvent {
  final String threadId;

  DeleteThreadEvent(this.threadId);
}
