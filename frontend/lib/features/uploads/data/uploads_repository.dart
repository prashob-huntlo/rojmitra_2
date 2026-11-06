import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error.dart';
import '../../../core/network/api_client.dart';

class UploadsRepository {
  UploadsRepository(this._dio);

  final Dio _dio;
  final Dio _plainDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Never _throwApiError(DioException e) {
    final err = e.error;
    if (err is ApiError) throw err;
    throw ApiError.fromDioException(e);
  }

  String _contentTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  /// Uploads a local image to GCS via a backend-issued signed URL.
  /// Returns the durable object key to store on the worker document.
  Future<String> uploadImage({
    required String localPath,
    required String kind,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw const ApiError(code: 'file_missing', error: 'Selected image was not found');
    }

    final contentType = _contentTypeForPath(localPath);

    late final Map<String, dynamic> signed;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/uploads/signed-url',
        data: {
          'contentType': contentType,
          'kind': kind,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ApiError(code: 'server_error', error: 'Could not start image upload');
      }
      signed = data;
    } on DioException catch (e) {
      _throwApiError(e);
    }

    final uploadUrl = signed['uploadUrl']?.toString();
    final objectKey = signed['objectKey']?.toString();
    if (uploadUrl == null || uploadUrl.isEmpty || objectKey == null || objectKey.isEmpty) {
      throw const ApiError(code: 'server_error', error: 'Invalid upload response');
    }

    final headers = <String, dynamic>{'Content-Type': contentType};
    final signedHeaders = signed['headers'];
    if (signedHeaders is Map) {
      signedHeaders.forEach((key, value) {
        if (value != null) headers[key.toString()] = value.toString();
      });
    }

    try {
      final bytes = await file.readAsBytes();
      await _plainDio.put<void>(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: headers,
          contentType: contentType,
        ),
      );
    } on DioException catch (e) {
      throw ApiError(
        code: 'upload_failed',
        error: 'Image upload failed (${e.response?.statusCode ?? 'network'})',
      );
    }

    return objectKey;
  }

  Future<String> signedReadUrl(String objectKey) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/uploads/signed-read',
        data: {'objectKey': objectKey},
      );
      final url = response.data?['readUrl']?.toString();
      if (url == null || url.isEmpty) {
        throw const ApiError(code: 'server_error', error: 'Could not open image');
      }
      return url;
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }
}

final uploadsRepositoryProvider = Provider<UploadsRepository>((ref) {
  return UploadsRepository(ref.watch(dioProvider));
});

/// Cached signed read URLs so avatars / thumbs don't blank on every rebuild.
final signedReadUrlProvider =
    FutureProvider.family<String, String>((ref, objectKey) {
  return ref.watch(uploadsRepositoryProvider).signedReadUrl(objectKey);
});
