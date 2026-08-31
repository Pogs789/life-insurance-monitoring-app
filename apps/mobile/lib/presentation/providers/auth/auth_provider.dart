import 'package:flutter/material.dart';
import 'package:life_insurance_monitoring_mobile/core/errors/exceptions.dart';
import 'package:life_insurance_monitoring_mobile/domain/usecases/auth/auth_usecases.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/usecases/agent/agent_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(
    this._submitAgentUseCase,
    this._loginUseCase,
    this._refreshTokenUseCase,
    this._logoutUseCase,
    this._isLoggedInUseCase
  );
  final AgentUseCase _submitAgentUseCase;
  final LoginUseCase _loginUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final LogoutUseCase _logoutUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;
  bool _isLoggedIn = false;
  AuthStatus _authStatus = AuthStatus.unknown;
  bool get isLoggedInSync => _isLoggedIn;
  AuthStatus get authStatus => _authStatus;

  Future<void> initializeAuth() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _isLoggedInUseCase().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // If secure storage takes too long, assume user is not logged in
          return false;
        },
      );
      _isLoggedIn = result;
      _authStatus = result
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } on AppException catch (e) {
      errorMessage = e.message;
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> newAgentSubmit(UserEntity user) async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    try {
      final result = await _submitAgentUseCase(user);
      isSuccess = result['success'];
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    try {
      await _loginUseCase(email, password);
      isSuccess = true;
      _isLoggedIn = true;
      _authStatus = AuthStatus.authenticated;
    } on AppException catch (e) {
      errorMessage = e.message;
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshToken() async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    try {
      await _refreshTokenUseCase();
      isSuccess = true;
      _isLoggedIn = true;
      _authStatus = AuthStatus.authenticated;
    } on AppException catch (e) {
      errorMessage = e.message;
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isLoggedIn() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _isLoggedInUseCase().timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );
      _isLoggedIn = result;
      _authStatus = result
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      return result;
    } on AppException catch (e) {
      errorMessage = e.message;
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
      return false;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    try {
      await _logoutUseCase();
      isSuccess = true;
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
