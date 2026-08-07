import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_insurance_monitoring_mobile/core/constants/storage_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor(this.secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('Interceptor path: ${options.path}');
    final token = await secureStorage.read(key: StorageConstants.accessTokenKey);
    debugPrint('Token found by interceptor: ${token != null && token.isNotEmpty}');
    debugPrint('Token found by interceptor: $token');

    if(token != null && token.isNotEmpty){
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('[AuthInterceptor] Authorization header attached');
    } else {
      debugPrint('[AuthInterceptor] No token found in storage');
    }

    handler.next(options);
  }
}