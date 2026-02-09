import '../models/mailbox_model.dart';

/// Mailbox Events
abstract class MailboxEvent {}

/// Load all mailboxes for current user
class LoadMailboxesEvent extends MailboxEvent {}

/// Add a new mailbox
class AddMailboxEvent extends MailboxEvent {
  final MailboxCreateRequest request;

  AddMailboxEvent(this.request);
}

/// Test IMAP connection
class TestMailboxConnectionEvent extends MailboxEvent {
  final String imapHost;
  final int imapPort;
  final String username;
  final String password;

  TestMailboxConnectionEvent({
    required this.imapHost,
    required this.imapPort,
    required this.username,
    required this.password,
  });
}

/// Update mailbox
class UpdateMailboxEvent extends MailboxEvent {
  final String mailboxId;
  final Map<String, dynamic> updates;

  UpdateMailboxEvent({
    required this.mailboxId,
    required this.updates,
  });
}

/// Delete mailbox
class DeleteMailboxEvent extends MailboxEvent {
  final String mailboxId;

  DeleteMailboxEvent(this.mailboxId);
}

/// Refresh mailboxes
class RefreshMailboxesEvent extends MailboxEvent {}
