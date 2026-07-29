import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_insurance_monitoring_mobile/core/constants/storage_constants.dart';
import 'package:life_insurance_monitoring_mobile/data/models/auth_response_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthSessionModel session);
  Future<AuthSessionModel?> getSession();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<List<String>> getFullNameAndCompany();
  Future<String?> getUserId();
  Future<bool> hasAccessToken();
  Future<bool> hasRefreshToken();
  Future<void> clearSession();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    final sessionJson = jsonEncode(session.toJson());

    await _secureStorage.write(
      key: StorageConstants.sessionKey,
      value: sessionJson,
    );
    await _secureStorage.write(
      key: StorageConstants.accessTokenKey,
      value: session.accessToken,
    );
    await _secureStorage.write(
      key: StorageConstants.refreshTokenKey,
      value: session.refreshToken,
    );
    await _secureStorage.write(
      key: StorageConstants.fullName,
      value: session.fullName,
    );
    await _secureStorage.write(
      key: StorageConstants.companyId,
      value: session.companyId,
    );
    await _secureStorage.write(
      key: StorageConstants.insuranceCompany,
      value: session.insuranceCompany,
    );
    await _secureStorage.write(
      key: StorageConstants.userIdKey,
      value: session.userId,
    );
  }

  @override
  Future<AuthSessionModel?> getSession() async {
    final raw = await _secureStorage.read(key: StorageConstants.sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSessionModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getAccessToken() =>
      _secureStorage.read(key: StorageConstants.accessTokenKey);

  @override
  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: StorageConstants.refreshTokenKey);

  @override
  Future<String?> getUserId() async {
    final userId = await _secureStorage.read(key: StorageConstants.userIdKey);
    if (userId == null) return null;

    final trimmed = userId.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.trim().isNotEmpty;
  }

  @override
  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.trim().isNotEmpty;
  }

  @override
  Future<void> clearSession() async {
    await _secureStorage.delete(key: StorageConstants.sessionKey);
    await _secureStorage.delete(key: StorageConstants.accessTokenKey);
    await _secureStorage.delete(key: StorageConstants.fullName);
    await _secureStorage.delete(key: StorageConstants.insuranceCompany);
    await _secureStorage.delete(key: StorageConstants.refreshTokenKey);
    await _secureStorage.delete(key: StorageConstants.userIdKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    final hasToken = await hasAccessToken();
    return userId != null && hasToken;
  }

  @override
  Future<List<String>> getFullNameAndCompany() async {
    final String? fullName = await _secureStorage.read(key: StorageConstants.fullName);
    final String? insuranceCompany = await _secureStorage.read(key: StorageConstants.insuranceCompany);
    final String? companyId = await _secureStorage.read(key: StorageConstants.companyId);

    if(fullName == null || insuranceCompany == null || companyId == null) {
      await clearSession();
      return [];
    }

    return [fullName, insuranceCompany, companyId];
  }
}
