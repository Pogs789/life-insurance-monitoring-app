import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:life_insurance_monitoring_mobile/data/datasources/local/auth_local_datasource.dart';
import 'package:life_insurance_monitoring_mobile/data/models/auth_response_model.dart';
import 'package:life_insurance_monitoring_mobile/domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemote;
  final AuthLocalDataSource authLocal;
  AuthRepositoryImpl(this.authRemote, this.authLocal);

  @override
  Future<void> loginUser(String email, String password) async {
    final response = await authRemote.login(email, password);
    await authLocal.saveSession(response);
  }

  @override
  Future<void> logout() async {
    final String? userId = await authLocal.getUserId();
    final String? refreshToken = await authLocal.getRefreshToken();

    debugPrint("Logging out user with ID: $userId and refresh token: $refreshToken");

    if (userId == null || refreshToken == null) {
      await authLocal.clearSession();
      return;
    }

    debugPrint("Calling remote logout for user ID: $userId with refresh token: $refreshToken");

    await authRemote.logout(userId, refreshToken);
    await authLocal.clearSession();
  }

  @override
  Future<void> refreshToken() async {
    final String? userId = await authLocal.getUserId();
    final String? refreshToken = await authLocal.getRefreshToken();

    if (userId == null || refreshToken == null) {
      await authLocal.clearSession();
      return;
    }

    final refreshedSession = await authRemote.refreshToken(userId, refreshToken);
    await authLocal.saveSession(refreshedSession);
  }

  @override
  Future<bool> checkLoggedInUser() async {
    try {
      final sessionFuture = authLocal.getSession();
      final userIdFuture = authLocal.getUserId();

      // Use Future.wait with a timeout to prevent hanging
      final results = await Future.wait(
        [sessionFuture, userIdFuture],
        eagerError: true,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Secure storage access timed out'),
      );

      final session = results[0] as AuthSessionModel?;
      final loggedInUser = results[1] as String?;

      if (session == null || loggedInUser == null) {
        await authLocal.clearSession();
        return false;
      }

      // Check if access token is expired
      if (_isTokenExpired(session.accessToken)) {
        debugPrint("Access token is expired. Attempting to refresh...");

        try {
          await refreshToken();
          debugPrint("Token refresh successful");
          return true;
        } catch (e) {
          debugPrint("Token refresh failed: $e. Clearing session.");
          await authLocal.clearSession();
          return false;
        }
      }

      debugPrint("Access token is still valid");
      return true;
    } on TimeoutException catch (e) {
      debugPrint("Timeout checking logged in user: $e. Assuming not logged in.");
      return false;
    } catch (e) {
      debugPrint("Error checking logged in user: $e. Assuming not logged in.");
      return false;
    }
  }

  /// Checks if a JWT token is expired by decoding and checking the expiry time.
  /// Returns true if the token is expired, false if it's still valid.
  bool _isTokenExpired(String token) {
    try {
      final decoded = JWT.decode(token);
      final expiryTime = decoded.payload['exp'] as int?;

      if (expiryTime == null) {
        debugPrint("No expiry time found in token. Assuming token is valid.");
        return false;
      }

      // exp is in seconds since epoch. Compare with current time.
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final isExpired = currentTime >= expiryTime;

      if (isExpired) {
        debugPrint("Token expired at: ${DateTime.fromMillisecondsSinceEpoch(expiryTime * 1000)}, Current time: ${DateTime.now()}");
      }

      return isExpired;
    } on FormatException catch (e) {
      debugPrint("Failed to decode token: $e. Assuming token is invalid.");
      return true;
    } catch (e) {
      debugPrint("Error checking token expiry: $e. Assuming token is invalid.");
      return true;
    }
  }
}
