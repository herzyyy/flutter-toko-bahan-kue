class Role {
  final int id;
  final String name;
  final int createdAt;

  Role({required this.id, required this.name, required this.createdAt});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
    );
  }
}
