import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error.dart';
import '../../../core/network/api_client.dart';
import '../models/catalog_company.dart';
import '../models/catalog_job.dart';
import '../models/catalog_skill.dart';

class CatalogRepository {
  CatalogRepository(this._dio);

  final Dio _dio;

  Never _throwApiError(DioException e) {
    final err = e.error;
    if (err is ApiError) throw err;
    throw ApiError.fromDioException(e);
  }

  Future<List<CatalogCompany>> searchCompanies(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    try {
      final response = await _dio.get<List<dynamic>>(
        '/companies',
        queryParameters: {'q': q},
      );
      final raw = response.data ?? const [];
      return [
        for (final item in raw)
          if (item is Map<String, dynamic>) CatalogCompany.fromJson(item),
      ];
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }

  Future<CatalogCompany> addCompany(String name) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/companies',
        data: {'name': name.trim()},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiError(code: 'server_error', error: 'Something went wrong');
      }
      return CatalogCompany.fromJson(data);
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }

  Future<List<CatalogSkill>> searchSkills(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    try {
      final response = await _dio.get<List<dynamic>>(
        '/skills',
        queryParameters: {'q': q},
      );
      final raw = response.data ?? const [];
      return [
        for (final item in raw)
          if (item is Map<String, dynamic>) CatalogSkill.fromJson(item),
      ];
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }

  Future<List<CatalogJob>> searchJobs(String query) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/jobs',
        queryParameters: {
          'q': query.trim(),
          'limit': 20,
        },
      );
      final raw = response.data ?? const [];
      return [
        for (final item in raw)
          if (item is Map<String, dynamic>) CatalogJob.fromJson(item),
      ];
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }

  Future<CatalogSkill> addSkill(String name) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/skills',
        data: {'name': name.trim()},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiError(code: 'server_error', error: 'Something went wrong');
      }
      return CatalogSkill.fromJson(data);
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }

  Future<CatalogJob> addJob(String name) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/jobs',
        data: {'name': name.trim()},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiError(code: 'server_error', error: 'Something went wrong');
      }
      return CatalogJob.fromJson(data);
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(dioProvider));
});
