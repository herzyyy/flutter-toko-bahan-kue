import 'dart:convert';
import 'package:flutter_toko_bahan_kue/models/sale_model.dart';
import 'package:flutter_toko_bahan_kue/models/sale_detail_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';

class SaleApi {
  static const String baseUrl =
      'https://top-gibbon-engaged.ngrok-free.app'; // ganti sesuai

  // Fetch Sales
  static Future<List<Sale>> fetchSales(String search) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/sales?search=$search'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => Sale.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat riwayat penjualan');
    }
  }

  // Fetch Purchase
  static Future<List<Purchase>> fetchPurchase(String search) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/purchases?search=$search'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => Purchase.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat riwayat pembelian');
    }
  }

  static Future<SaleDetail> getSaleDetails(String saleCode) async {
    final token = await AuthService.getToken();

    final url = Uri.parse('$baseUrl/api/v1/sales/$saleCode');

    try {
      final response = await http.get(
        url,
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Authorization': token.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SaleDetail.fromJson(jsonData['data']);
      } else {
        throw Exception(
          'Gagal memuat detail penjualan: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
