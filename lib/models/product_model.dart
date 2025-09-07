// import 'category_model.dart';
import 'size_model.dart';

class Product {
  final String sku;
  final String name;
  // final Category category;
  final List<Size> sizes;

  Product({
    required this.sku,
    required this.name,
    // required this.category,
    required this.sizes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sku: json['sku'],
      name: json['name'],
      // category: Category.fromJson(json['category']),
      sizes: (json['sizes'] as List<dynamic>)
          .map((e) => Size.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      // 'category': category.toJson(),
      'sizes': sizes.map((e) => e.toJson()).toList(),
    };
  }
}
