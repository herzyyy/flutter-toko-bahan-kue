import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';

class ProductApi {
  static const String baseUrl =
      'https://top-gibbon-engaged.ngrok-free.app'; // Ganti dengan URL API Anda

  static Future<List<Product>> fetchProductList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/products'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'c3745237-b828-4653-b356-68f20e6cdda0',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Akses array matakuliah dari properti 'data'
      final List<dynamic> data = jsonResponse['data'];

      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }
}
