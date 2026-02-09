import 'package:intl/intl.dart';

/// Helper utilities for formatting and common operations
class Helpers {
  Helpers._();

  /// Format DateTime to readable string
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  /// Format number with thousand separators
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  /// Validate email address
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Get bounce type color
  static String getBounceTypeColor(String bounceType) {
    switch (bounceType.toUpperCase()) {
      case 'HARD':
        return '#EF4444'; // Red
      case 'SOFT':
        return '#F59E0B'; // Amber
      case 'UNKNOWN':
        return '#6B7280'; // Gray
      default:
        return '#6B7280';
    }
  }

  /// Get mailbox status color
  static String getMailboxStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return '#10B981'; // Green
      case 'ERROR':
        return '#EF4444'; // Red
      case 'DISABLED':
        return '#6B7280'; // Gray
      default:
        return '#6B7280';
    }
  }

  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
