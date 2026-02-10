import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/email_service.dart';
import 'email_event.dart';
import 'email_state.dart';

/// Email BLoC - Business Logic Component for Emails
class EmailBloc extends Bloc<EmailEvent, EmailState> {
  final EmailService _emailService;

  // Keep track of current filters for pagination
  String? _currentCategory;
  String? _currentMailboxId;
  String? _currentThreadId;
  String? _currentSearch;
  bool? _currentIsRead;
  bool? _currentIsStarred;
  bool? _currentIsArchived;
  int _currentLimit = 50;

  EmailBloc(this._emailService) : super(EmailInitial()) {
    on<LoadEmailsEvent>(_onLoadEmails);
    on<LoadMoreEmailsEvent>(_onLoadMoreEmails);
    on<RefreshEmailsEvent>(_onRefreshEmails);
    on<LoadEmailDetailEvent>(_onLoadEmailDetail);
    on<LoadCategoryCountsEvent>(_onLoadCategoryCounts);
    on<MarkEmailAsReadEvent>(_onMarkEmailAsRead);
    on<ToggleEmailStarEvent>(_onToggleEmailStar);
    on<ToggleEmailArchiveEvent>(_onToggleEmailArchive);
    on<DeleteEmailEvent>(_onDeleteEmail);
    on<SearchEmailsEvent>(_onSearchEmails);
    on<ClearMessageEvent>(_onClearMessage);
  }

  /// Load emails with filters
  Future<void> _onLoadEmails(
    LoadEmailsEvent event,
    Emitter<EmailState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        // Keep current data visible while refreshing
        if (state is EmailLoaded) {
          // Don't show loading, just refresh in background
        } else {
          emit(EmailLoading());
        }
      } else {
        emit(EmailLoading());
      }

      // Store current filters
      _currentCategory = event.category;
      _currentMailboxId = event.mailboxId;
      _currentThreadId = event.threadId;
      _currentSearch = event.search;
      _currentIsRead = event.isRead;
      _currentIsStarred = event.isStarred;
      _currentIsArchived = event.isArchived;
      _currentLimit = event.limit;

      final response = await _emailService.fetchEmails(
        category: event.category,
        mailboxId: event.mailboxId,
        threadId: event.threadId,
        search: event.search,
        isRead: event.isRead,
        isStarred: event.isStarred,
        isArchived: event.isArchived,
        limit: event.limit,
        offset: event.offset,
      );

      if (response.data.isEmpty) {
        emit(EmailEmpty());
      } else {
        final hasMore = response.data.length >= event.limit;
        emit(
          EmailLoaded(
            emails: response.data,
            total: response.total,
            hasMore: hasMore,
            currentOffset: event.offset,
            currentCategory: event.category,
          ),
        );
      }
    } catch (e) {
      log('❌ [EmailBloc] Error loading emails: $e', error: e);
      emit(EmailError(e.toString()));
    }
  }

  /// Load more emails (pagination)
  Future<void> _onLoadMoreEmails(
    LoadMoreEmailsEvent event,
    Emitter<EmailState> emit,
  ) async {
    if (state is! EmailLoaded) return;

    final currentState = state as EmailLoaded;
    if (!currentState.hasMore) return;

    try {
      emit(
        EmailLoadingMore(
          currentEmails: currentState.emails,
          currentOffset: currentState.currentOffset,
        ),
      );

      final newOffset = currentState.currentOffset + _currentLimit;

      final response = await _emailService.fetchEmails(
        category: _currentCategory,
        mailboxId: _currentMailboxId,
        threadId: _currentThreadId,
        search: _currentSearch,
        isRead: _currentIsRead,
        isStarred: _currentIsStarred,
        isArchived: _currentIsArchived,
        limit: _currentLimit,
        offset: newOffset,
      );

      final updatedEmails = [...currentState.emails, ...response.data];
      final hasMore = response.data.length >= _currentLimit;

      emit(
        EmailLoaded(
          emails: updatedEmails,
          total: response.total,
          hasMore: hasMore,
          currentOffset: newOffset,
          currentCategory: _currentCategory,
          categoryCounts: currentState.categoryCounts,
        ),
      );
    } catch (e) {
      log('❌ [EmailBloc] Error loading more emails: $e', error: e);
      emit(EmailError(e.toString()));
    }
  }

  /// Refresh emails
  Future<void> _onRefreshEmails(
    RefreshEmailsEvent event,
    Emitter<EmailState> emit,
  ) async {
    add(
      LoadEmailsEvent(
        category: event.category ?? _currentCategory,
        mailboxId: event.mailboxId ?? _currentMailboxId,
        isRefresh: true,
      ),
    );
  }

  /// Load single email detail
  Future<void> _onLoadEmailDetail(
    LoadEmailDetailEvent event,
    Emitter<EmailState> emit,
  ) async {
    try {
      emit(EmailLoading());

      final email = await _emailService.getEmail(event.emailId);

      emit(EmailDetailLoaded(email));
    } catch (e) {
      log('❌ [EmailBloc] Error loading email detail: $e', error: e);
      emit(EmailError(e.toString()));
    }
  }

  /// Load category counts
  Future<void> _onLoadCategoryCounts(
    LoadCategoryCountsEvent event,
    Emitter<EmailState> emit,
  ) async {
    try {
      final categoryCounts = await _emailService.getCategoryCounts();

      if (state is EmailLoaded) {
        emit((state as EmailLoaded).copyWith(categoryCounts: categoryCounts));
      } else {
        emit(CategoryCountsLoaded(categoryCounts));
      }
    } catch (e) {
      log('❌ [EmailBloc] Error loading category counts: $e', error: e);
      // Don't emit error state, just log it
    }
  }

  /// Mark email as read/unread
  Future<void> _onMarkEmailAsRead(
    MarkEmailAsReadEvent event,
    Emitter<EmailState> emit,
  ) async {
    final previousState = state;

    try {
      final updatedEmail = await _emailService.markAsRead(
        event.emailId,
        event.isRead,
      );

      // Update the email in current list if loaded
      if (previousState is EmailLoaded) {
        final updatedEmails = previousState.emails.map((email) {
          return email.id == event.emailId ? updatedEmail : email;
        }).toList();

        emit(
          previousState.copyWith(
            emails: updatedEmails,
            message: event.isRead ? 'Marked as read' : 'Marked as unread',
          ),
        );
      } else if (previousState is EmailDetailLoaded) {
        emit(EmailDetailLoaded(updatedEmail));
      }
    } catch (e) {
      log('❌ [EmailBloc] Error marking email as read: $e', error: e);
      if (previousState is EmailLoaded) {
        emit(previousState);
      }
      emit(EmailError(e.toString()));
    }
  }

  /// Toggle email star
  Future<void> _onToggleEmailStar(
    ToggleEmailStarEvent event,
    Emitter<EmailState> emit,
  ) async {
    final previousState = state;

    try {
      final updatedEmail = await _emailService.toggleStar(
        event.emailId,
        event.isStarred,
      );

      // Update the email in current list if loaded
      if (previousState is EmailLoaded) {
        final updatedEmails = previousState.emails.map((email) {
          return email.id == event.emailId ? updatedEmail : email;
        }).toList();

        emit(
          previousState.copyWith(
            emails: updatedEmails,
            message: event.isStarred ? 'Starred' : 'Unstarred',
          ),
        );
      } else if (previousState is EmailDetailLoaded) {
        emit(EmailDetailLoaded(updatedEmail));
      }
    } catch (e) {
      log('❌ [EmailBloc] Error toggling star: $e', error: e);
      if (previousState is EmailLoaded) {
        emit(previousState);
      }
      emit(EmailError(e.toString()));
    }
  }

  /// Toggle email archive
  Future<void> _onToggleEmailArchive(
    ToggleEmailArchiveEvent event,
    Emitter<EmailState> emit,
  ) async {
    final previousState = state;

    try {
      await _emailService.toggleArchive(event.emailId, event.isArchived);

      // Remove from list if archived
      if (previousState is EmailLoaded && event.isArchived) {
        final updatedEmails = previousState.emails
            .where((email) => email.id != event.emailId)
            .toList();

        emit(
          previousState.copyWith(
            emails: updatedEmails,
            message: event.isArchived ? 'Archived' : 'Unarchived',
          ),
        );
      }
    } catch (e) {
      log('❌ [EmailBloc] Error toggling archive: $e', error: e);
      if (previousState is EmailLoaded) {
        emit(previousState);
      }
      emit(EmailError(e.toString()));
    }
  }

  /// Delete email
  Future<void> _onDeleteEmail(
    DeleteEmailEvent event,
    Emitter<EmailState> emit,
  ) async {
    final previousState = state;

    try {
      await _emailService.deleteEmail(event.emailId);

      // Remove from list if loaded
      if (previousState is EmailLoaded) {
        final updatedEmails = previousState.emails
            .where((email) => email.id != event.emailId)
            .toList();

        emit(
          previousState.copyWith(
            emails: updatedEmails,
            message: 'Email deleted',
          ),
        );
      }
    } catch (e) {
      log('❌ [EmailBloc] Error deleting email: $e', error: e);
      if (previousState is EmailLoaded) {
        emit(previousState);
      }
      emit(EmailError(e.toString()));
    }
  }

  /// Search emails
  Future<void> _onSearchEmails(
    SearchEmailsEvent event,
    Emitter<EmailState> emit,
  ) async {
    add(LoadEmailsEvent(search: event.query, isRefresh: true));
  }

  /// Clear message from EmailLoaded state
  void _onClearMessage(ClearMessageEvent event, Emitter<EmailState> emit) {
    if (state is EmailLoaded) {
      emit((state as EmailLoaded).copyWith(clearMessage: true));
    }
  }
}
