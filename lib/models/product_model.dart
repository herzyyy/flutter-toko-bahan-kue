import 'package:flutter_toko_bahan_kue/models/size_model.dart';

class Product {
  final String branchName;
  final String sku;
  final String name;
  final List<Size> sizes;

  Product({
    required this.branchName,
    required this.sku,
    required this.name,
    required this.sizes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      branchName: json['branch_name'] ?? '',
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      sizes:
          (json['sizes'] as List?)?.map((e) => Size.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_name': branchName,
      'sku': sku,
      'name': name,
      'sizes': sizes.map((e) => e.toJson()).toList(),
    };
  }
}
