import 'package:equatable/equatable.dart';

/// Bounce Model - represents an email bounce record
class BounceModel extends Equatable {
  final String id;
  final String userId;
  final String mailboxId;
  final String email;
  final String bounceType; // HARD, SOFT, UNKNOWN
  final String errorCode;
  final String? reason;
  final int failureCount;
  final DateTime firstFailedAt;
  final DateTime lastFailedAt;
  final DateTime createdAt;

  const BounceModel({
    required this.id,
    required this.userId,
    required this.mailboxId,
    required this.email,
    required this.bounceType,
    required this.errorCode,
    this.reason,
    required this.failureCount,
    required this.firstFailedAt,
    required this.lastFailedAt,
    required this.createdAt,
  });

  factory BounceModel.fromJson(Map<String, dynamic> json) {
    return BounceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mailboxId: json['mailbox_id'] as String,
      email: json['email'] as String,
      bounceType: json['bounce_type'] as String,
      errorCode: json['error_code'] as String,
      reason: json['reason'] as String?,
      failureCount: json['failure_count'] as int,
      firstFailedAt: DateTime.parse(json['first_failed_at'] as String),
      lastFailedAt: DateTime.parse(json['last_failed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mailbox_id': mailboxId,
      'email': email,
      'bounce_type': bounceType,
      'error_code': errorCode,
      'reason': reason,
      'failure_count': failureCount,
      'first_failed_at': firstFailedAt.toIso8601String(),
      'last_failed_at': lastFailedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    mailboxId,
    email,
    bounceType,
    errorCode,
    reason,
    failureCount,
    firstFailedAt,
    lastFailedAt,
    createdAt,
  ];
}

/// Bounce List Response
class BounceListResponse extends Equatable {
  final List<BounceModel> data;
  final int total;

  const BounceListResponse({required this.data, required this.total});

  factory BounceListResponse.fromJson(Map<String, dynamic> json) {
    return BounceListResponse(
      data: (json['data'] as List)
          .map((item) => BounceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }

  @override
  List<Object?> get props => [data, total];
}

/// Unique Count Response
class UniqueCountResponse extends Equatable {
  final int total;
  final int hard;
  final int soft;
  final int unknown;

  const UniqueCountResponse({
    required this.total,
    required this.hard,
    required this.soft,
    required this.unknown,
  });

  factory UniqueCountResponse.fromJson(Map<String, dynamic> json) {
    return UniqueCountResponse(
      total: json['total'] as int,
      hard: json['hard'] as int,
      soft: json['soft'] as int,
      unknown: json['unknown'] as int,
    );
  }

  @override
  List<Object?> get props => [total, hard, soft, unknown];
}

/// Bounce Stats Response
class BounceStatsResponse extends Equatable {
  final int totalFailures;
  final int uniqueEmails;
  final Map<String, int> byType;
  final int recentCount;
  final int last7Days;

  const BounceStatsResponse({
    required this.totalFailures,
    required this.uniqueEmails,
    required this.byType,
    required this.recentCount,
    required this.last7Days,
  });

  factory BounceStatsResponse.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase (API) and snake_case (legacy) keys
    final totalFailures =
        json['totalFailures'] as int? ?? json['total_failures'] as int? ?? 0;
    final uniqueEmails =
        json['uniqueEmails'] as int? ?? json['unique_emails'] as int? ?? 0;
    final byTypeMap =
        json['byType'] as Map<String, dynamic>? ??
        json['by_type'] as Map<String, dynamic>? ??
        {};
    final recentCount =
        json['recentCount'] as int? ?? json['recent_count'] as int? ?? 0;

    // Handle trend object
    final trend = json['trend'] as Map<String, dynamic>? ?? {};
    final last7Days = trend['last7Days'] as int? ?? 0;

    return BounceStatsResponse(
      totalFailures: totalFailures,
      uniqueEmails: uniqueEmails,
      byType: Map<String, int>.from(byTypeMap),
      recentCount: recentCount,
      last7Days: last7Days,
    );
  }

  @override
  List<Object?> get props => [
    totalFailures,
    uniqueEmails,
    byType,
    recentCount,
    last7Days,
  ];
}

/// Trend Data for Charts
class TrendData extends Equatable {
  final DateTime date;
  final int count;

  const TrendData({required this.date, required this.count});

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      date: DateTime.parse(json['date'] as String),
      count: json['count'] as int,
    );
  }

  @override
  List<Object?> get props => [date, count];
}
