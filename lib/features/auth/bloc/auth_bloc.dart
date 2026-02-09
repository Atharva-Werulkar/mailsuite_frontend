import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/auth_model.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC - Manages authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<RefreshTokenEvent>(_onRefreshToken);
  }

  /// Extract clean error message from exception
  String _extractErrorMessage(dynamic error) {
    final errorString = error.toString();
    log('🔍 [AuthBloc] Extracting error from: $errorString');

    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      final cleaned = errorString.substring('Exception: '.length);
      log('✂️ [AuthBloc] Cleaned error message: $cleaned');
      return cleaned;
    }

    return errorString;
  }

  /// Handle Login Event
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    log('📥 [AuthBloc] LoginEvent received - email: ${event.email}');

    try {
      log('⏳ [AuthBloc] Emitting AuthLoading state');
      emit(AuthLoading());

      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );

      final authResponse = await _authService.login(request);

      log('✅ [AuthBloc] Login successful - user: ${authResponse.user.email}');
      emit(AuthLoginSuccess(authResponse.user));
      emit(AuthAuthenticated(authResponse.user));
    } catch (e) {
      log('❌ [AuthBloc] Login error: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [AuthBloc] User-facing error: $errorMessage');
      emit(AuthError(errorMessage));
      emit(AuthUnauthenticated());
    }
  }

  /// Handle Register Event
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    log('📥 [AuthBloc] RegisterEvent received - email: ${event.email}');

    try {
      log('⏳ [AuthBloc] Emitting AuthLoading state');
      emit(AuthLoading());

      final request = RegisterRequest(
        email: event.email,
        password: event.password,
        name: event.name,
      );

      final authResponse = await _authService.register(request);

      log(
        '✅ [AuthBloc] Registration successful - user: ${authResponse.user.email}',
      );
      emit(AuthRegistrationSuccess(authResponse.user));
      emit(AuthAuthenticated(authResponse.user));
    } catch (e) {
      log('❌ [AuthBloc] Registration error: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [AuthBloc] User-facing error: $errorMessage');
      emit(AuthError(errorMessage));
      emit(AuthUnauthenticated());
    }
  }

  /// Handle Logout Event
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    log('📥 [AuthBloc] LogoutEvent received');

    try {
      log('⏳ [AuthBloc] Logging out...');
      emit(AuthLoading());

      await _authService.logout();

      log('✅ [AuthBloc] Logout successful');
      emit(AuthLogoutSuccess());
      emit(AuthUnauthenticated());
    } catch (e) {
      log('❌ [AuthBloc] Logout error: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [AuthBloc] User-facing error: $errorMessage');
      emit(AuthError(errorMessage));
    }
  }

  /// Handle Check Auth Status Event
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    log('📥 [AuthBloc] CheckAuthStatusEvent received');

    try {
      log('⏳ [AuthBloc] Checking authentication status...');

      final isAuthenticated = await _authService.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authService.getStoredUser();

        if (user != null) {
          log('✅ [AuthBloc] User is authenticated - email: ${user.email}');
          emit(AuthAuthenticated(user));
        } else {
          log('⚠️ [AuthBloc] User token exists but user data not found');
          emit(AuthUnauthenticated());
        }
      } else {
        log('⚠️ [AuthBloc] User is not authenticated');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      log('❌ [AuthBloc] Error checking auth status: $e', error: e);
      emit(AuthUnauthenticated());
    }
  }

  /// Handle Get Current User Event
  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    log('📥 [AuthBloc] GetCurrentUserEvent received');

    try {
      log('⏳ [AuthBloc] Fetching current user...');
      emit(AuthLoading());

      final user = await _authService.getCurrentUser();

      if (user != null) {
        log('✅ [AuthBloc] Current user fetched - email: ${user.email}');
        emit(AuthAuthenticated(user));
      } else {
        log('⚠️ [AuthBloc] No current user found');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      log('❌ [AuthBloc] Error fetching current user: $e', error: e);
      final errorMessage = _extractErrorMessage(e);
      log('💬 [AuthBloc] User-facing error: $errorMessage');
      emit(AuthError(errorMessage));
      emit(AuthUnauthenticated());
    }
  }

  /// Handle Refresh Token Event
  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    log('📥 [AuthBloc] RefreshTokenEvent received');

    try {
      log('⏳ [AuthBloc] Refreshing token...');

      final success = await _authService.refreshToken();

      if (success) {
        log('✅ [AuthBloc] Token refreshed successfully');

        final user = await _authService.getStoredUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        }
      } else {
        log('⚠️ [AuthBloc] Token refresh failed');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      log('❌ [AuthBloc] Error refreshing token: $e', error: e);
      emit(AuthUnauthenticated());
    }
  }
}
