import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';

class ProductApi {
  static const String baseUrl =
      'https://top-gibbon-engaged.ngrok-free.app'; // Ganti dengan URL API Anda

  static Future<List<Product>> fetchProductList(String query) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/branch-inventory?search=$query'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      final List<dynamic> data = jsonResponse['data'];

      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }
}
