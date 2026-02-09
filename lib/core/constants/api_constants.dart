import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Constants and Configuration
class ApiConstants {
  ApiConstants._();

  // Base URLs
  static final String baseUrl = String.fromEnvironment(
    dotenv.env['API_BASE_URL']!,
    defaultValue: 'http://192.168.29.8:3000',
  );

  // API Endpoints
  // Authentication
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String authMe = '/api/v1/auth/me';
  static const String authLogout = '/api/v1/auth/logout';

  // Bounces
  static const String bounces = '/api/v1/bounces';
  static const String bouncesUnique = '/api/v1/bounces/unique';
  static const String bouncesStats = '/api/v1/bounces/stats';

  // Mailboxes
  static const String mailboxes = '/api/v1/mailboxes';

  // Emails
  static const String emails = '/api/v1/emails';
  static const String emailsCategories = '/api/v1/emails/categories';

  // Threads
  static const String threads = '/api/v1/threads';
  static const String threadsStats = '/api/v1/threads/stats';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
}
