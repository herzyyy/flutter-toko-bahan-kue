class Branch {
  final int id;
  final String name;
  final String address;
  final int createdAt;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      createdAt: json['created_at'],
    );
  }
}
