import 'package:equatable/equatable.dart';
import '../models/mailbox_model.dart';

/// Mailbox States
abstract class MailboxState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial State
class MailboxInitial extends MailboxState {}

/// Loading State
class MailboxLoading extends MailboxState {}

/// Loaded State
class MailboxLoaded extends MailboxState {
  final List<MailboxModel> mailboxes;

  MailboxLoaded(this.mailboxes);

  @override
  List<Object?> get props => [mailboxes];
}

/// Error State
class MailboxError extends MailboxState {
  final String message;

  MailboxError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Connection Testing State
class MailboxConnectionTesting extends MailboxState {}

/// Connection Test Success
class MailboxConnectionSuccess extends MailboxState {
  final String message;

  MailboxConnectionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Connection Test Failed
class MailboxConnectionFailed extends MailboxState {
  final String message;

  MailboxConnectionFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Mailbox Added Successfully
class MailboxAdded extends MailboxState {
  final MailboxModel mailbox;

  MailboxAdded(this.mailbox);

  @override
  List<Object?> get props => [mailbox];
}

/// Mailbox Updated Successfully
class MailboxUpdated extends MailboxState {
  final MailboxModel mailbox;

  MailboxUpdated(this.mailbox);

  @override
  List<Object?> get props => [mailbox];
}

/// Mailbox Deleted Successfully
class MailboxDeleted extends MailboxState {
  final String mailboxId;

  MailboxDeleted(this.mailboxId);

  @override
  List<Object?> get props => [mailboxId];
}
