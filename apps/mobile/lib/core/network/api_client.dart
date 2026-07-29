import 'package:dio/dio.dart';
import 'package:life_insurance_monitoring_mobile/core/errors/exceptions.dart';

class ApiClient {
  ApiClient({required this.dio});

  final Dio dio;

  /// GET - Fetch a single item
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await dio.get(
        endpoint,
        options: Options(contentType: Headers.jsonContentType),
      );
      return response.data;
    } catch (e, stackTrace) {
      throw mapToAppException(e, stackTrace);
    }
  }

  /// GET - Fetch multiple items with query parameters
  Future<Map<String, dynamic>> getWithParams(
    String endpoint,
    Map<String, dynamic>? queryParameters,
  ) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(contentType: Headers.jsonContentType),
      );
      return response.data;
    } catch (e, stackTrace) {
      throw mapToAppException(e, stackTrace);
    }
  }

  /// POST - Create a new item
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
      return response.data;
    } catch (e, stackTrace) {
      throw mapToAppException(e, stackTrace);
    }
  }

  /// PUT - Update an existing item
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.put(
        endpoint,
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
      return response.data;
    } catch (e, stackTrace) {
      throw mapToAppException(e, stackTrace);
    }
  }

  /// DELETE - Delete an item
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await dio.delete(
        endpoint,
        options: Options(contentType: Headers.jsonContentType),
      );
      return response.data;
    } catch (e, stackTrace) {
      throw mapToAppException(e, stackTrace);
    }
  }
}
