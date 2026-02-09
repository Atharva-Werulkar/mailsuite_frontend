import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

/// Authentication Service - Handles all auth-related API calls
class AuthService {
  final ApiClient _apiClient;

  // Keys for storing tokens
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  AuthService(this._apiClient);

  /// Register new user
  Future<AuthResponseModel> register(RegisterRequest request) async {
    log('🌐 [AuthService] Registering user - email: ${request.email}');

    try {
      log('📡 [AuthService] API Request: POST ${ApiConstants.authRegister}');
      final response = await _apiClient.post(
        ApiConstants.authRegister,
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _saveTokens(authResponse);
      log(
        '✅ [AuthService] User registered successfully - id: ${authResponse.user.id}',
      );

      return authResponse;
    } catch (e) {
      log('❌ [AuthService] Error registering user: $e', error: e);
      rethrow; // Rethrow original error without wrapping
    }
  }

  /// Login user
  Future<AuthResponseModel> login(LoginRequest request) async {
    log('🌐 [AuthService] Logging in user - email: ${request.email}');

    try {
      log('📡 [AuthService] API Request: POST ${ApiConstants.authLogin}');
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _saveTokens(authResponse);
      log(
        '✅ [AuthService] User logged in successfully - id: ${authResponse.user.id}',
      );

      return authResponse;
    } catch (e) {
      log('❌ [AuthService] Error logging in: $e', error: e);
      rethrow; // Rethrow original error without wrapping
    }
  }

  /// Logout user
  Future<void> logout() async {
    log('🌐 [AuthService] Logging out user');

    try {
      await _clearTokens();
      log('✅ [AuthService] User logged out successfully');
    } catch (e) {
      log('❌ [AuthService] Error logging out: $e', error: e);
      throw Exception('Failed to logout: $e');
    }
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    log('🌐 [AuthService] Refreshing access token');

    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      log('⚠️ [AuthService] No refresh token available');
      return false;
    }

    try {
      log('📡 [AuthService] API Request: POST ${ApiConstants.authRefresh}');
      final response = await _apiClient.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      await _saveTokensFromJson(data);

      log('✅ [AuthService] Access token refreshed successfully');
      return true;
    } catch (e) {
      log('❌ [AuthService] Error refreshing token: $e', error: e);
      return false;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    log('🌐 [AuthService] Getting current user');

    try {
      log('📡 [AuthService] API Request: GET ${ApiConstants.authMe}');
      final response = await _apiClient.get(ApiConstants.authMe);

      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await _saveUser(user);

      log('✅ [AuthService] Current user retrieved - id: ${user.id}');
      return user;
    } catch (e) {
      log('❌ [AuthService] Error getting current user: $e', error: e);
      return null;
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Get stored user
  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) return null;

    try {
      // Decode JSON string to Map
      final Map<String, dynamic> userMap =
          jsonDecode(userJson) as Map<String, dynamic>;
      log('📖 [AuthService] User data decoded successfully');
      return UserModel.fromJson(userMap);
    } catch (e) {
      log('❌ [AuthService] Error parsing stored user: $e', error: e);
      log('🧹 [AuthService] Clearing corrupted auth data');

      // Clear corrupted data - user will need to login again
      await _clearTokens();

      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  /// Save tokens to storage
  Future<void> _saveTokens(AuthResponseModel authResponse) async {
    log('💾 [AuthService] Saving tokens to storage');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, authResponse.accessToken);
    await prefs.setString(_refreshTokenKey, authResponse.refreshToken);
    await _saveUser(authResponse.user);
  }

  /// Save tokens from JSON
  Future<void> _saveTokensFromJson(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    if (data.containsKey('accessToken')) {
      await prefs.setString(_accessTokenKey, data['accessToken'] as String);
    }

    if (data.containsKey('refreshToken')) {
      await prefs.setString(_refreshTokenKey, data['refreshToken'] as String);
    }

    if (data.containsKey('user')) {
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveUser(user);
    }
  }

  /// Save user to storage
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    // Encode Map to JSON string
    final userJson = jsonEncode(user.toJson());
    log('💾 [AuthService] Saving user data - id: ${user.id}');
    await prefs.setString(_userKey, userJson);
  }

  /// Clear all tokens
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }
}
