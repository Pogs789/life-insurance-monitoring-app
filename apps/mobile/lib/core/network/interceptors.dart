import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_insurance_monitoring_mobile/core/constants/storage_constants.dart';
import 'package:life_insurance_monitoring_mobile/core/constants/api_endpoints.dart';

class AuthInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage secureStorage;
  final Dio dio;

  // Shared future used to deduplicate concurrent refresh attempts
  Future<void>? _refreshFuture;

  AuthInterceptor(this.secureStorage, this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('Interceptor path: ${options.path}');
    final token = await secureStorage.read(key: StorageConstants.accessTokenKey);
    debugPrint('Token found by interceptor: ${token != null && token.isNotEmpty}');
    debugPrint('Token found by interceptor: $token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('[AuthInterceptor] Authorization header attached');
    } else {
      debugPrint('[AuthInterceptor] No token found in storage');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;

    // Only attempt refresh on 401 and avoid infinite retry loops using an extra flag
    if (statusCode == 401 && requestOptions.extra['retried'] != true) {
      try {
        // If a refresh is already in progress, wait for it; otherwise start one
        if (_refreshFuture != null) {
          await _refreshFuture;
        } else {
          _refreshFuture = _refreshToken();
          await _refreshFuture;
        }
      } catch (e) {
        // Refresh failed: clear future and forward original error (user should re-login)
        _refreshFuture = null;
        return handler.next(err);
      }

      // Clear the shared future after refresh completes
      _refreshFuture = null;

      // Retry the original request with the new token
      try {
        final newToken = await secureStorage.read(key: StorageConstants.accessTokenKey);

        final newHeaders = Map<String, dynamic>.from(requestOptions.headers);
        if (newToken != null && newToken.isNotEmpty) {
          newHeaders['Authorization'] = 'Bearer $newToken';
        }

        final opts = Options(
          method: requestOptions.method,
          headers: newHeaders,
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
          followRedirects: requestOptions.followRedirects,
          validateStatus: requestOptions.validateStatus,
          receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
          extra: Map<String, dynamic>.from(requestOptions.extra)..['retried'] = true,
        );

        final response = await dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: opts,
          cancelToken: requestOptions.cancelToken,
          onReceiveProgress: requestOptions.onReceiveProgress,
          onSendProgress: requestOptions.onSendProgress,
        );

        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  Future<void> _refreshToken() async {
    final userId = await secureStorage.read(key: StorageConstants.userIdKey);
    final refreshToken = await secureStorage.read(key: StorageConstants.refreshTokenKey);

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID not available for token refresh');
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    // Use a fresh Dio instance so the refresh request does not go through the same interceptors
    final refreshDio = Dio();

    try {
      final response = await refreshDio.post(
        ApiEndpoints.refreshApi,
        data: {'userId': userId, 'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccess = data['access_token'] ?? data['accessToken'] ?? data['access'];
        final newRefresh = data['refresh_token'] ?? data['refreshToken'] ?? data['refresh'];

        if (newAccess != null) {
          await secureStorage.write(key: StorageConstants.accessTokenKey, value: newAccess.toString());
        }
        if (newRefresh != null) {
          await secureStorage.write(key: StorageConstants.refreshTokenKey, value: newRefresh.toString());
        }
      } else {
        throw Exception('Token refresh failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}