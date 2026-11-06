import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error.dart';
import '../../../core/network/api_client.dart';

class LegalDocument {
  const LegalDocument({
    required this.slug,
    required this.lang,
    required this.title,
    required this.body,
    this.updatedAt,
  });

  final String slug;
  final String lang;
  final String title;
  final String body;
  final DateTime? updatedAt;

  List<String> get paragraphs => body
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      slug: json['slug']?.toString() ?? '',
      lang: json['lang']?.toString() ?? 'en',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class LegalRepository {
  LegalRepository(this._dio);

  final Dio _dio;

  Never _throwApiError(DioException e) {
    final err = e.error;
    if (err is ApiError) throw err;
    throw ApiError.fromDioException(e);
  }

  Future<LegalDocument> fetch(String slug, {String? lang}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/legal/$slug',
        queryParameters: {
          if (lang != null && lang.isNotEmpty) 'lang': lang,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ApiError(code: 'not_found', error: 'Document not found');
      }
      return LegalDocument.fromJson(data);
    } on DioException catch (e) {
      _throwApiError(e);
    }
  }
}

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  return LegalRepository(ref.watch(dioProvider));
});

final legalDocumentProvider =
    FutureProvider.family<LegalDocument, String>((ref, slug) {
  return ref.watch(legalRepositoryProvider).fetch(slug);
});
