import 'package:equatable/equatable.dart';

/// Mailbox Model - represents a connected email mailbox
class MailboxModel extends Equatable {
  final String id;
  final String userId;
  final String provider;
  final String emailAddress;
  final String imapHost;
  final int imapPort;
  final String imapUsername;
  final String status; // ACTIVE, ERROR, DISABLED
  final String? lastError;
  final int lastSyncedUid;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;

  const MailboxModel({
    required this.id,
    required this.userId,
    required this.provider,
    required this.emailAddress,
    required this.imapHost,
    required this.imapPort,
    required this.imapUsername,
    required this.status,
    this.lastError,
    required this.lastSyncedUid,
    this.lastSyncedAt,
    required this.createdAt,
  });

  factory MailboxModel.fromJson(Map<String, dynamic> json) {
    return MailboxModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      provider: json['provider'] as String,
      emailAddress: json['email_address'] as String,
      imapHost: json['imap_host'] as String,
      imapPort: json['imap_port'] as int,
      imapUsername: json['imap_username'] as String,
      status: json['status'] as String,
      lastError: json['last_error'] as String?,
      lastSyncedUid: json['last_synced_uid'] as int? ?? 0,
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider': provider,
      'email_address': emailAddress,
      'imap_host': imapHost,
      'imap_port': imapPort,
      'imap_username': imapUsername,
      'status': status,
      'last_error': lastError,
      'last_synced_uid': lastSyncedUid,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        provider,
        emailAddress,
        imapHost,
        imapPort,
        imapUsername,
        status,
        lastError,
        lastSyncedUid,
        lastSyncedAt,
        createdAt,
      ];
}

/// Mailbox Create Request
class MailboxCreateRequest {
  final String emailAddress;
  final String imapHost;
  final int imapPort;
  final String imapUsername;
  final String imapPassword;
  final String provider;

  MailboxCreateRequest({
    required this.emailAddress,
    required this.imapHost,
    required this.imapPort,
    required this.imapUsername,
    required this.imapPassword,
    this.provider = 'gmail',
  });

  Map<String, dynamic> toJson() {
    return {
      'email_address': emailAddress,
      'imap_host': imapHost,
      'imap_port': imapPort,
      'imap_username': imapUsername,
      'imap_password': imapPassword,
      'provider': provider,
    };
  }
}
