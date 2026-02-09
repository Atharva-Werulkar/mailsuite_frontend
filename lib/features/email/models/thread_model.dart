import 'package:equatable/equatable.dart';

import 'email_model.dart';

/// Email Thread Model - represents a conversation thread
class EmailThreadModel extends Equatable {
  final String id;
  final String userId;
  final String mailboxId;
  final String subject;
  final String normalizedSubject;
  final List<String> participants;
  final int messageCount;
  final bool isUnread;
  final bool isArchived;
  final DateTime firstMessageAt;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<EmailModel>? messages; // Populated when fetching thread details

  const EmailThreadModel({
    required this.id,
    required this.userId,
    required this.mailboxId,
    required this.subject,
    required this.normalizedSubject,
    required this.participants,
    required this.messageCount,
    required this.isUnread,
    required this.isArchived,
    required this.firstMessageAt,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });

  factory EmailThreadModel.fromJson(Map<String, dynamic> json) {
    return EmailThreadModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mailboxId: json['mailbox_id'] as String,
      subject: json['subject'] as String,
      normalizedSubject:
          json['normalized_subject'] as String? ?? json['subject'] as String,
      participants: (json['participants'] as List?)?.cast<String>() ?? [],
      messageCount: json['message_count'] as int? ?? 0,
      isUnread: json['is_unread'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      firstMessageAt: DateTime.parse(json['first_message_at'] as String),
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messages: json['messages'] != null
          ? (json['messages'] as List)
                .map(
                  (item) => EmailModel.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mailbox_id': mailboxId,
      'subject': subject,
      'normalized_subject': normalizedSubject,
      'participants': participants,
      'message_count': messageCount,
      'is_unread': isUnread,
      'is_archived': isArchived,
      'first_message_at': firstMessageAt.toIso8601String(),
      'last_message_at': lastMessageAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'messages': messages?.map((m) => m.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    mailboxId,
    subject,
    normalizedSubject,
    participants,
    messageCount,
    isUnread,
    isArchived,
    firstMessageAt,
    lastMessageAt,
    createdAt,
    updatedAt,
    messages,
  ];

  EmailThreadModel copyWith({
    String? id,
    String? userId,
    String? mailboxId,
    String? subject,
    String? normalizedSubject,
    List<String>? participants,
    int? messageCount,
    bool? isUnread,
    bool? isArchived,
    DateTime? firstMessageAt,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<EmailModel>? messages,
  }) {
    return EmailThreadModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mailboxId: mailboxId ?? this.mailboxId,
      subject: subject ?? this.subject,
      normalizedSubject: normalizedSubject ?? this.normalizedSubject,
      participants: participants ?? this.participants,
      messageCount: messageCount ?? this.messageCount,
      isUnread: isUnread ?? this.isUnread,
      isArchived: isArchived ?? this.isArchived,
      firstMessageAt: firstMessageAt ?? this.firstMessageAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }
}

/// Thread List Response
class ThreadListResponse extends Equatable {
  final List<EmailThreadModel> data;
  final int total;

  const ThreadListResponse({required this.data, required this.total});

  factory ThreadListResponse.fromJson(Map<String, dynamic> json) {
    return ThreadListResponse(
      data: (json['data'] as List)
          .map(
            (item) => EmailThreadModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [data, total];
}

/// Thread Stats Response
class ThreadStatsResponse extends Equatable {
  final int total;
  final int unread;
  final int archived;
  final int active;

  const ThreadStatsResponse({
    required this.total,
    required this.unread,
    required this.archived,
    required this.active,
  });

  factory ThreadStatsResponse.fromJson(Map<String, dynamic> json) {
    return ThreadStatsResponse(
      total: json['total'] as int? ?? 0,
      unread: json['unread'] as int? ?? 0,
      archived: json['archived'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [total, unread, archived, active];
}
