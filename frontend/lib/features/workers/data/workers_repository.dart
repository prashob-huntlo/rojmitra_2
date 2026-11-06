import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error.dart';
import '../../../core/network/api_client.dart';
import '../../../workers/worker.dart';

class WorkersRepository {
  WorkersRepository(this._dio);

  final Dio _dio;

  Never _throwApiError(DioException e) {
    final err = e.error;
    if (err is ApiError) throw err;
    throw ApiError.fromDioException(e);
  }

  Future<List<Worker>> list({int limit = 50}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/workers',
        queryParameters: {'limit': limit, 'page': 1},
      );
      final items = response.data?['items'];
      if (items is! List) return const [];
      return [
        for (final item in items)
          if (item is Map) Worker.fromJson(Map<String, dynamic>.from(item)),
      ];
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }

  Future<Worker> getById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/workers/$id');
      final data = response.data;
      if (data == null) {
        throw const ApiError(code: 'not_found', error: 'Worker not found');
      }
      return Worker.fromJson(data);
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }

  Future<Worker> setAvailability({
    required String id,
    required bool isReadyToWork,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/workers/$id/availability',
        data: {'isReadyToWork': isReadyToWork},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiError(code: 'server_error', error: 'Something went wrong');
      }
      return Worker.fromJson(data);
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }

  Future<Worker> create(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/workers',
        data: body,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiError(code: 'server_error', error: 'Something went wrong');
      }
      return Worker.fromJson(data);
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }

  Future<Worker> update(String id, Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/workers/$id',
        data: body,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiError(code: 'server_error', error: 'Something went wrong');
      }
      return Worker.fromJson(data);
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }
}

final workersRepositoryProvider = Provider<WorkersRepository>((ref) {
  return WorkersRepository(ref.watch(dioProvider));
});
