import 'dart:convert';
import 'package:flutter_toko_bahan_kue/models/history_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';

class HistoryApi {
  static const String baseUrl =
      'https://top-gibbon-engaged.ngrok-free.app'; // ganti sesuai

  // Fetch Sales History
  static Future<List<SaleHistory>> fetchSalesHistory() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/sales'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => SaleHistory.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat riwayat penjualan');
    }
  }

  // Fetch Purchase History
  static Future<List<PurchaseHistory>> fetchPurchaseHistory() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/purchases'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => PurchaseHistory.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat riwayat pembelian');
    }
  }
}
