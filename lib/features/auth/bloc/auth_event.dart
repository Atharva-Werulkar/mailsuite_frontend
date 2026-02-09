/// Authentication Events
abstract class AuthEvent {}

/// Login Event
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

/// Register Event
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String? name;

  RegisterEvent({required this.email, required this.password, this.name});
}

/// Logout Event
class LogoutEvent extends AuthEvent {}

/// Check Authentication Status Event
class CheckAuthStatusEvent extends AuthEvent {}

/// Get Current User Event
class GetCurrentUserEvent extends AuthEvent {}

/// Refresh Token Event
class RefreshTokenEvent extends AuthEvent {}
