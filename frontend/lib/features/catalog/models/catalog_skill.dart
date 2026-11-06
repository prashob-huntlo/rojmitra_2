class CatalogSkill {
  const CatalogSkill({required this.id, required this.name});

  final String id;
  final String name;

  factory CatalogSkill.fromJson(Map<String, dynamic> json) {
    return CatalogSkill(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
