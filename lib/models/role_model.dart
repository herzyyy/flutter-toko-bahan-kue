class Role {
  final int id;
  final String name;
  final int createdAt;
  // final int updatedAt;

  Role({
    required this.id,
    required this.name,
    required this.createdAt,
    // required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      // updatedAt: json['updated_at'],
    );
  }
}
