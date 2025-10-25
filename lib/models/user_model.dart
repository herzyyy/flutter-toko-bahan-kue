import 'package:flutter_toko_bahan_kue/models/branch_model.dart';
import 'package:flutter_toko_bahan_kue/models/role_model.dart';

class User {
  final String username;
  final String name;
  final String address;
  final int createdAt;
  final Role role;
  final Branch branch;

  User({
    required this.username,
    required this.name,
    required this.address,
    required this.createdAt,
    required this.role,
    required this.branch,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      name: json['name'],
      address: json['address'],
      createdAt: json['created_at'],
      role: Role.fromJson(json['role']),
      branch: Branch.fromJson(json['branch']),
    );
  }
}
