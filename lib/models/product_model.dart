import 'category_model.dart';
import 'size_model.dart';

class Product {
  final String sku;
  final String name;
  final int createdAt;
  final int updatedAt;
  final Category category;
  final List<Size> sizes;

  Product({
    required this.sku,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.sizes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sku: json['sku'],
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      category: Category.fromJson(json['category']),
      sizes: (json['sizes'] as List<dynamic>)
          .map((e) => Size.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'category': category.toJson(),
      'sizes': sizes.map((e) => e.toJson()).toList(),
    };
  }
}
