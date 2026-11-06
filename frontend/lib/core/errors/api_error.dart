import 'package:dio/dio.dart';

class ApiError implements Exception {
  const ApiError({
    required this.code,
    required this.error,
    this.fields,
    this.statusCode,
  });

  final String code;
  final String error;
  final Map<String, dynamic>? fields;
  final int? statusCode;

  factory ApiError.fromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final code = data['code'];
      final error = data['error'];
      if (code is String && error is String) {
        final rawFields = data['fields'];
        return ApiError(
          code: code,
          error: error,
          fields: rawFields is Map
              ? Map<String, dynamic>.from(rawFields)
              : null,
          statusCode: e.response?.statusCode,
        );
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiError(
        code: 'network_error',
        error: 'Network error',
        statusCode: e.response?.statusCode,
      );
    }

    return ApiError(
      code: 'server_error',
      error: 'Something went wrong',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => 'ApiError($code): $error';
}
