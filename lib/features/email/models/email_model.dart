import 'package:equatable/equatable.dart';

/// Email Model - represents a full email with classification
class EmailModel extends Equatable {
  final String id;
  final String userId;
  final String mailboxId;
  final int uid;
  final String messageId;
  final String? subject;
  final String fromAddress;
  final String? fromName;
  final List<String> toAddresses;
  final List<String>? ccAddresses;
  final List<String>? bccAddresses;
  final String
  category; // BOUNCE, TRANSACTIONAL, NOTIFICATION, MARKETING, HUMAN, NEWSLETTER
  final String? threadId;
  final String? inReplyTo;
  final List<String>? references;
  final bool hasAttachments;
  final bool isRead;
  final bool isStarred;
  final bool isArchived;
  final DateTime receivedAt;
  final DateTime? sentAt;
  final int? sizeBytes;
  final Map<String, dynamic>? headers;
  final String? bodyPreview;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmailModel({
    required this.id,
    required this.userId,
    required this.mailboxId,
    required this.uid,
    required this.messageId,
    this.subject,
    required this.fromAddress,
    this.fromName,
    required this.toAddresses,
    this.ccAddresses,
    this.bccAddresses,
    required this.category,
    this.threadId,
    this.inReplyTo,
    this.references,
    required this.hasAttachments,
    required this.isRead,
    required this.isStarred,
    this.isArchived = false,
    required this.receivedAt,
    this.sentAt,
    this.sizeBytes,
    this.headers,
    this.bodyPreview,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mailboxId: json['mailbox_id'] as String,
      uid: json['uid'] as int,
      messageId: json['message_id'] as String,
      subject: json['subject'] as String?,
      fromAddress: json['from_address'] as String,
      fromName: json['from_name'] as String?,
      toAddresses: (json['to_addresses'] as List?)?.cast<String>() ?? [],
      ccAddresses: (json['cc_addresses'] as List?)?.cast<String>(),
      bccAddresses: (json['bcc_addresses'] as List?)?.cast<String>(),
      category: json['category'] as String,
      threadId: json['thread_id'] as String?,
      inReplyTo: json['in_reply_to'] as String?,
      references: (json['references'] as List?)?.cast<String>(),
      hasAttachments: json['has_attachments'] as bool? ?? false,
      isRead: json['is_read'] as bool? ?? false,
      isStarred: json['is_starred'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      receivedAt: DateTime.parse(json['received_at'] as String),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      sizeBytes: json['size_bytes'] as int?,
      headers: json['headers'] as Map<String, dynamic>?,
      bodyPreview: json['body_preview'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mailbox_id': mailboxId,
      'uid': uid,
      'message_id': messageId,
      'subject': subject,
      'from_address': fromAddress,
      'from_name': fromName,
      'to_addresses': toAddresses,
      'cc_addresses': ccAddresses,
      'bcc_addresses': bccAddresses,
      'category': category,
      'thread_id': threadId,
      'in_reply_to': inReplyTo,
      'references': references,
      'has_attachments': hasAttachments,
      'is_read': isRead,
      'is_starred': isStarred,
      'is_archived': isArchived,
      'received_at': receivedAt.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'size_bytes': sizeBytes,
      'headers': headers,
      'body_preview': bodyPreview,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    mailboxId,
    uid,
    messageId,
    subject,
    fromAddress,
    fromName,
    toAddresses,
    ccAddresses,
    bccAddresses,
    category,
    threadId,
    inReplyTo,
    references,
    hasAttachments,
    isRead,
    isStarred,
    isArchived,
    receivedAt,
    sentAt,
    sizeBytes,
    headers,
    bodyPreview,
    createdAt,
    updatedAt,
  ];

  EmailModel copyWith({
    String? id,
    String? userId,
    String? mailboxId,
    int? uid,
    String? messageId,
    String? subject,
    String? fromAddress,
    String? fromName,
    List<String>? toAddresses,
    List<String>? ccAddresses,
    List<String>? bccAddresses,
    String? category,
    String? threadId,
    String? inReplyTo,
    List<String>? references,
    bool? hasAttachments,
    bool? isRead,
    bool? isStarred,
    bool? isArchived,
    DateTime? receivedAt,
    DateTime? sentAt,
    int? sizeBytes,
    Map<String, dynamic>? headers,
    String? bodyPreview,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmailModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mailboxId: mailboxId ?? this.mailboxId,
      uid: uid ?? this.uid,
      messageId: messageId ?? this.messageId,
      subject: subject ?? this.subject,
      fromAddress: fromAddress ?? this.fromAddress,
      fromName: fromName ?? this.fromName,
      toAddresses: toAddresses ?? this.toAddresses,
      ccAddresses: ccAddresses ?? this.ccAddresses,
      bccAddresses: bccAddresses ?? this.bccAddresses,
      category: category ?? this.category,
      threadId: threadId ?? this.threadId,
      inReplyTo: inReplyTo ?? this.inReplyTo,
      references: references ?? this.references,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      isArchived: isArchived ?? this.isArchived,
      receivedAt: receivedAt ?? this.receivedAt,
      sentAt: sentAt ?? this.sentAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      headers: headers ?? this.headers,
      bodyPreview: bodyPreview ?? this.bodyPreview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Email List Response
class EmailListResponse extends Equatable {
  final List<EmailModel> data;
  final int total;

  const EmailListResponse({required this.data, required this.total});

  factory EmailListResponse.fromJson(Map<String, dynamic> json) {
    return EmailListResponse(
      data: (json['data'] as List)
          .map((item) => EmailModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [data, total];
}

/// Category Counts Response
class CategoryCountsResponse extends Equatable {
  final Map<String, int> total;
  final Map<String, int>? unread;

  const CategoryCountsResponse({required this.total, this.unread});

  factory CategoryCountsResponse.fromJson(Map<String, dynamic> json) {
    return CategoryCountsResponse(
      total:
          (json['total'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      unread: (json['unread'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }

  @override
  List<Object?> get props => [total, unread];
}
