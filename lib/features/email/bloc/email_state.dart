import 'package:equatable/equatable.dart';

import '../models/email_model.dart';

/// Email States
abstract class EmailState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial State
class EmailInitial extends EmailState {}

/// Loading State
class EmailLoading extends EmailState {}

/// Loaded State
class EmailLoaded extends EmailState {
  final List<EmailModel> emails;
  final int total;
  final bool hasMore;
  final int currentOffset;
  final String? currentCategory;
  final CategoryCountsResponse? categoryCounts;

  EmailLoaded({
    required this.emails,
    required this.total,
    required this.hasMore,
    required this.currentOffset,
    this.currentCategory,
    this.categoryCounts,
  });

  @override
  List<Object?> get props => [
        emails,
        total,
        hasMore,
        currentOffset,
        currentCategory,
        categoryCounts,
      ];

  EmailLoaded copyWith({
    List<EmailModel>? emails,
    int? total,
    bool? hasMore,
    int? currentOffset,
    String? currentCategory,
    CategoryCountsResponse? categoryCounts,
  }) {
    return EmailLoaded(
      emails: emails ?? this.emails,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      currentCategory: currentCategory ?? this.currentCategory,
      categoryCounts: categoryCounts ?? this.categoryCounts,
    );
  }
}

/// Loading More State (for pagination)
class EmailLoadingMore extends EmailState {
  final List<EmailModel> currentEmails;
  final int currentOffset;

  EmailLoadingMore({
    required this.currentEmails,
    required this.currentOffset,
  });

  @override
  List<Object?> get props => [currentEmails, currentOffset];
}

/// Email Detail Loaded
class EmailDetailLoaded extends EmailState {
  final EmailModel email;

  EmailDetailLoaded(this.email);

  @override
  List<Object?> get props => [email];
}

/// Email Updated (after marking read, star, archive)
class EmailUpdated extends EmailState {
  final EmailModel email;
  final String message;

  EmailUpdated({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

/// Email Deleted
class EmailDeleted extends EmailState {
  final String emailId;
  final String message;

  EmailDeleted({required this.emailId, required this.message});

  @override
  List<Object?> get props => [emailId, message];
}

/// Category Counts Loaded
class CategoryCountsLoaded extends EmailState {
  final CategoryCountsResponse categoryCounts;

  CategoryCountsLoaded(this.categoryCounts);

  @override
  List<Object?> get props => [categoryCounts];
}

/// Error State
class EmailError extends EmailState {
  final String message;

  EmailError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty State
class EmailEmpty extends EmailState {
  final String message;

  EmailEmpty({this.message = 'No emails found'});

  @override
  List<Object?> get props => [message];
}
