class CatalogCompany {
  const CatalogCompany({required this.id, required this.name});

  final String id;
  final String name;

  factory CatalogCompany.fromJson(Map<String, dynamic> json) {
    return CatalogCompany(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
