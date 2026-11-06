class CatalogJob {
  const CatalogJob({required this.id, required this.name});

  final String id;
  final String name;

  factory CatalogJob.fromJson(Map<String, dynamic> json) {
    return CatalogJob(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
