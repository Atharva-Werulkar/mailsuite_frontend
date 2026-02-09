/// Application Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'MailSuite';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // Bounce Types
  static const String bounceTypeHard = 'HARD';
  static const String bounceTypeSoft = 'SOFT';
  static const String bounceTypeUnknown = 'UNKNOWN';

  // Mailbox Status
  static const String mailboxStatusActive = 'ACTIVE';
  static const String mailboxStatusError = 'ERROR';
  static const String mailboxStatusDisabled = 'DISABLED';

  // Default IMAP Settings
  static const String gmailImapHost = 'imap.gmail.com';
  static const int gmailImapPort = 993;
}
