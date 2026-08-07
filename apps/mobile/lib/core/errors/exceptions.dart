import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

sealed class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const AppException(this.message, {this.statusCode, this.cause});

  @override
  String toString() =>
      'AppException(message: $message, statusCode: $statusCode, cause: $cause)';
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode, super.cause});
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.cause});
}

final class RequestTimeoutException extends AppException {
  const RequestTimeoutException(super.message, {super.statusCode, super.cause});
}

final class AuthException extends AppException {
  const AuthException(super.message, {super.statusCode, super.cause});
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.statusCode, super.cause});
}

final class UnknownException extends AppException {
  const UnknownException(super.message, {super.statusCode, super.cause});
}

String? _extractValidationMessage(dynamic data) {
  if (data == null) return null;

  dynamic normalized = data;

  // If backend sent plain JSON string, decode it.
  if (normalized is String) {
    try {
      normalized = jsonDecode(normalized);
    } catch (_) {
      return normalized.trim().isEmpty ? null : normalized;
    }
  }

  if (normalized is Map<String, dynamic>) {
    // Common API fields
    final direct =
        normalized['message'] ??
        normalized['error'] ??
        normalized['detail'] ??
        normalized['title'];
    if (direct is String && direct.trim().isNotEmpty) return direct;

    // Common validation structures:
    // { errors: ["a", "b"] }
    // { errors: { email: ["invalid"], password: ["too short"] } }
    final errors = normalized['message'];
    if (errors is List) {
      final lines = errors
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
      if (lines.isNotEmpty) return lines.join('\n');
    }

    if (errors is Map<String, dynamic>) {
      final lines = <String>[];
      errors.forEach((field, value) {
        if (value is List) {
          for (final v in value) {
            lines.add('$field: $v');
          }
        } else {
          lines.add('$field: $value');
        }
      });
      if (lines.isNotEmpty) return lines.join('\n');
    }

    // Fallback: stringify full payload
    return jsonEncode(normalized);
  }

  if (normalized is List) {
    return normalized.map((e) => e.toString()).join('\n');
  }

  return normalized.toString();
}

AppException mapToAppException(Object error, StackTrace stackTrace) {

  debugPrint("Stack Trace: $stackTrace");

  if (error is AppException) return error;

  if (error is DioException) {
    final statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return RequestTimeoutException(
          'Request timed out. Please Try again in a few minutes.',
          statusCode: statusCode,
          cause: error,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return NetworkException(
          'Network Connection Failed. Please Try Again.',
          statusCode: statusCode,
          cause: error,
        );
      case DioExceptionType.badResponse:
        final backendMessage = _extractValidationMessage(error.response?.data);

        if (statusCode == 401 || statusCode == 403) {
          debugPrint('This transaction is UnAuthorized. Error: $backendMessage');
          return AuthException(
            backendMessage ?? 'This request is Unauthorized.',
            statusCode: statusCode,
            cause: error,
          );
        }
        // TODO: This is the exception where it should be placed under the text.
        if (statusCode == 400 || statusCode == 422) {
          return ValidationException(
            backendMessage ??
                'Validation Failed. Please check your inputs and try again.',
            statusCode: statusCode,
            cause: error,
          );
        }

        return ServerException(
          backendMessage ?? 'Server Error Occurred.',
          statusCode: statusCode,
          cause: error,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          'Request cancelled by user.',
          statusCode: statusCode,
          cause: error,
        );
      case DioExceptionType.unknown:
        return UnknownException(
          'Unexpected network error',
          statusCode: statusCode,
          cause: error,
        );
    }
  }

  return UnknownException('Unexpected application error', cause: error);
}
