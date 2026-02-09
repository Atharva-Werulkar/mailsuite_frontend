import 'package:equatable/equatable.dart';

import '../models/user_model.dart';

/// Authentication States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial State
class AuthInitial extends AuthState {}

/// Loading State
class AuthLoading extends AuthState {}

/// Authenticated State
class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated State
class AuthUnauthenticated extends AuthState {}

/// Error State
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Registration Success State
class AuthRegistrationSuccess extends AuthState {
  final UserModel user;

  AuthRegistrationSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Login Success State
class AuthLoginSuccess extends AuthState {
  final UserModel user;

  AuthLoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Logout Success State
class AuthLogoutSuccess extends AuthState {}
