/// Email Events
abstract class EmailEvent {}

/// Load emails with filters
class LoadEmailsEvent extends EmailEvent {
  final String? category;
  final String? mailboxId;
  final String? threadId;
  final String? search;
  final bool? isRead;
  final bool? isStarred;
  final bool? isArchived;
  final int limit;
  final int offset;
  final bool isRefresh;

  LoadEmailsEvent({
    this.category,
    this.mailboxId,
    this.threadId,
    this.search,
    this.isRead,
    this.isStarred,
    this.isArchived,
    this.limit = 50,
    this.offset = 0,
    this.isRefresh = false,
  });
}

/// Load more emails (pagination)
class LoadMoreEmailsEvent extends EmailEvent {}

/// Refresh emails
class RefreshEmailsEvent extends EmailEvent {
  final String? category;
  final String? mailboxId;

  RefreshEmailsEvent({this.category, this.mailboxId});
}

/// Load single email
class LoadEmailDetailEvent extends EmailEvent {
  final String emailId;

  LoadEmailDetailEvent(this.emailId);
}

/// Load category counts
class LoadCategoryCountsEvent extends EmailEvent {}

/// Mark email as read/unread
class MarkEmailAsReadEvent extends EmailEvent {
  final String emailId;
  final bool isRead;

  MarkEmailAsReadEvent({required this.emailId, required this.isRead});
}

/// Toggle email star
class ToggleEmailStarEvent extends EmailEvent {
  final String emailId;
  final bool isStarred;

  ToggleEmailStarEvent({required this.emailId, required this.isStarred});
}

/// Toggle email archive
class ToggleEmailArchiveEvent extends EmailEvent {
  final String emailId;
  final bool isArchived;

  ToggleEmailArchiveEvent({required this.emailId, required this.isArchived});
}

/// Delete email
class DeleteEmailEvent extends EmailEvent {
  final String emailId;

  DeleteEmailEvent(this.emailId);
}

/// Search emails
class SearchEmailsEvent extends EmailEvent {
  final String query;

  SearchEmailsEvent(this.query);
}
