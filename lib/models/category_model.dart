class Category {
  final String slug;
  final String name;
  final int createdAt;
  final int updatedAt;

  Category({
    required this.slug,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      slug: json['slug'],
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
