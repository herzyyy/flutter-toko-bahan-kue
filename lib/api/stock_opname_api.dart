import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';

class StockOpnameApi {
  static const String baseUrl = 'http://localhost:9090';

  static Future<void> createStockOpname(Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/api/v1/stock-opname');

    try {
      final response = await http.post(
        url,
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Authorization': token.toString(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Gagal membuat riwayat pembelian: '
          '${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuat pembelian: $e');
    }
  }
}
