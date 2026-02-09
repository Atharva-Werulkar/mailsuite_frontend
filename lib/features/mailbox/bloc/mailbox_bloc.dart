import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/mailbox_service.dart';
import 'mailbox_event.dart';
import 'mailbox_state.dart';

/// Mailbox BLoC - Manages mailbox-related state
class MailboxBloc extends Bloc<MailboxEvent, MailboxState> {
  final MailboxService _mailboxService;

  MailboxBloc(this._mailboxService) : super(MailboxInitial()) {
    on<LoadMailboxesEvent>(_onLoadMailboxes);
    on<AddMailboxEvent>(_onAddMailbox);
    on<TestMailboxConnectionEvent>(_onTestConnection);
    on<UpdateMailboxEvent>(_onUpdateMailbox);
    on<DeleteMailboxEvent>(_onDeleteMailbox);
    on<RefreshMailboxesEvent>(_onRefreshMailboxes);
  }

  /// Extract clean error message from exception
  String _extractErrorMessage(dynamic error) {
    final errorString = error.toString();
    log('🔍 [MailboxBloc] Extracting error from: $errorString');

    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      final cleaned = errorString.substring('Exception: '.length);
      log('✂️ [MailboxBloc] Cleaned error message: $cleaned');
      return cleaned;
    }

    return errorString;
  }

  /// Handle Load Mailboxes Event
  Future<void> _onLoadMailboxes(
    LoadMailboxesEvent event,
    Emitter<MailboxState> emit,
  ) async {
    log('📥 [MailboxBloc] LoadMailboxesEvent received');

    try {
      log('⏳ [MailboxBloc] Emitting MailboxLoading state');
      emit(MailboxLoading());

      final mailboxes = await _mailboxService.fetchMailboxes();
      log(
        '✅ [MailboxBloc] Mailboxes loaded successfully - count: ${mailboxes.length}',
      );

      emit(MailboxLoaded(mailboxes));
    } catch (e) {
      log('❌ [MailboxBloc] Error loading mailboxes: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [MailboxBloc] User-facing error: $errorMessage');
      emit(MailboxError(errorMessage));
    }
  }

  /// Handle Add Mailbox Event
  Future<void> _onAddMailbox(
    AddMailboxEvent event,
    Emitter<MailboxState> emit,
  ) async {
    log(
      '➕ [MailboxBloc] AddMailboxEvent received - email: ${event.request.emailAddress}',
    );

    try {
      log('⏳ [MailboxBloc] Adding mailbox...');
      emit(MailboxLoading());

      final mailbox = await _mailboxService.addMailbox(event.request);
      log(
        '✅ [MailboxBloc] Mailbox added successfully - id: ${mailbox.id}, email: ${mailbox.emailAddress}',
      );

      emit(MailboxAdded(mailbox));

      // Reload mailboxes
      log('🔄 [MailboxBloc] Reloading mailboxes after add');
      add(LoadMailboxesEvent());
    } catch (e) {
      log('❌ [MailboxBloc] Error adding mailbox: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [MailboxBloc] User-facing error: $errorMessage');
      emit(MailboxError(errorMessage));
    }
  }

  /// Handle Test Connection Event
  Future<void> _onTestConnection(
    TestMailboxConnectionEvent event,
    Emitter<MailboxState> emit,
  ) async {
    log(
      '🔌 [MailboxBloc] TestMailboxConnectionEvent received - host: ${event.imapHost}:${event.imapPort}',
    );

    try {
      log('⏳ [MailboxBloc] Testing connection...');
      emit(MailboxConnectionTesting());

      final success = await _mailboxService.testConnection(
        host: event.imapHost,
        port: event.imapPort,
        username: event.username,
        password: event.password,
      );

      if (success) {
        log('✅ [MailboxBloc] Connection test successful');
        emit(MailboxConnectionSuccess('Connection successful!'));
      } else {
        log('⚠️ [MailboxBloc] Connection test failed');
        emit(MailboxConnectionFailed('Connection failed'));
      }
    } catch (e) {
      log('❌ [MailboxBloc] Connection test error: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [MailboxBloc] User-facing error: $errorMessage');
      emit(MailboxConnectionFailed(errorMessage));
    }
  }

  /// Handle Update Mailbox Event
  Future<void> _onUpdateMailbox(
    UpdateMailboxEvent event,
    Emitter<MailboxState> emit,
  ) async {
    log(
      '✏️ [MailboxBloc] UpdateMailboxEvent received - mailboxId: ${event.mailboxId}',
    );

    try {
      log('⏳ [MailboxBloc] Updating mailbox...');
      emit(MailboxLoading());

      final mailbox = await _mailboxService.updateMailbox(
        event.mailboxId,
        event.updates,
      );
      log('✅ [MailboxBloc] Mailbox updated successfully');

      emit(MailboxUpdated(mailbox));

      // Reload mailboxes
      log('🔄 [MailboxBloc] Reloading mailboxes after update');
      add(LoadMailboxesEvent());
    } catch (e) {
      log('❌ [MailboxBloc] Error updating mailbox: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [MailboxBloc] User-facing error: $errorMessage');
      emit(MailboxError(errorMessage));
    }
  }

  /// Handle Delete Mailbox Event
  Future<void> _onDeleteMailbox(
    DeleteMailboxEvent event,
    Emitter<MailboxState> emit,
  ) async {
    log(
      '🗑️ [MailboxBloc] DeleteMailboxEvent received - mailboxId: ${event.mailboxId}',
    );

    try {
      log('⏳ [MailboxBloc] Deleting mailbox...');
      emit(MailboxLoading());

      await _mailboxService.deleteMailbox(event.mailboxId);
      log('✅ [MailboxBloc] Mailbox deleted successfully');

      emit(MailboxDeleted(event.mailboxId));

      // Reload mailboxes
      log('🔄 [MailboxBloc] Reloading mailboxes after delete');
      add(LoadMailboxesEvent());
    } catch (e) {
      log('❌ [MailboxBloc] Error deleting mailbox: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [MailboxBloc] User-facing error: $errorMessage');
      emit(MailboxError(errorMessage));
    }
  }

  /// Handle Refresh Mailboxes Event
  Future<void> _onRefreshMailboxes(
    RefreshMailboxesEvent event,
    Emitter<MailboxState> emit,
  ) async {
    log('🔄 [MailboxBloc] RefreshMailboxesEvent received');
    add(LoadMailboxesEvent());
  }
}
