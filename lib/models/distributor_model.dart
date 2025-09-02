class Distributor {
  final int id;
  final String name;
  final String address;

  Distributor({required this.id, required this.name, required this.address});

  factory Distributor.fromJson(Map<String, dynamic> json) {
    return Distributor(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address};
  }
}
