import 'dart:convert';
import 'package:flutter_toko_bahan_kue/models/sale_create_model.dart';
import 'package:flutter_toko_bahan_kue/models/sale_model.dart';
import 'package:flutter_toko_bahan_kue/models/sale_detail_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';

class SaleApi {
  static const String baseUrl = 'http://localhost:9090'; // ganti sesuai

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

  static Future<Map<String, dynamic>> fetchSalesWithPagination(
    String salesSearchQuery, {
    String? search,
    int page = 1,
    int limit = 10, // Jumlah item per halaman
  }) async {
    final token = await AuthService.getToken();

    // Membuat query parameters
    final queryParams = {
      'reference_type': 'SALE',
      'page': page.toString(),
      'size': limit.toString(),
    };

    // Tambahkan parameter pencarian jika tersedia
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final url = Uri.parse(
      "$baseUrl/api/v1/sales",
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      url,
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Ekstrak data utama
      final List<dynamic> list = data['data'];
      final sales = list.map((e) => Sale.fromJson(e)).toList();

      // Ekstrak metadata paginasi
      final paging = data['paging'];
      final totalPages = paging['total_page'];
      final currentPage = paging['page'];
      final totalItems = paging['total_item'];

      return {
        'data': sales,
        'pagination': {
          'currentPage': currentPage,
          'totalPages': totalPages,
          'totalItems': totalItems,
          'perPage': limit,
        },
      };
    } else {
      throw Exception("Failed to load sales: ${response.statusCode}");
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

  static Future<Map<String, dynamic>> fetchPurchasesWithPagination(
    String purchasesSearchQuery, {
    String? search,
    int page = 1,
    int limit = 10, // Jumlah item per halaman
  }) async {
    final token = await AuthService.getToken();

    // Membuat query parameters
    final queryParams = {
      'reference_type': 'PURCHASE',
      'page': page.toString(),
      'size': limit.toString(),
    };

    // Tambahkan parameter pencarian jika tersedia
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final url = Uri.parse(
      "$baseUrl/api/v1/purchases",
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      url,
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Ekstrak data utama
      final List<dynamic> list = data['data'];
      final purchases = list.map((e) => Purchase.fromJson(e)).toList();

      // Ekstrak metadata paginasi
      final paging = data['paging'];
      final totalPages = paging['total_page'];
      final currentPage = paging['page'];
      final totalItems = paging['total_item'];

      return {
        'data': purchases,
        'pagination': {
          'currentPage': currentPage,
          'totalPages': totalPages,
          'totalItems': totalItems,
          'perPage': limit,
        },
      };
    } else {
      throw Exception("Failed to load purchases: ${response.statusCode}");
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

  // static Future<SaleDetail> createSale(Transaction transaction) async {
  //   final token = await AuthService.getToken();
  //   final url = Uri.parse('$baseUrl/api/v1/sales');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'ngrok-skip-browser-warning': 'true',
  //         'Authorization': token.toString(),
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(transaction.toJson()),
  //     );

  //     if (response.statusCode == 204) {
  //       final jsonData = json.decode(response.body);
  //       return SaleDetail.fromJson(jsonData['data']);
  //     } else {
  //       throw Exception(
  //         'Gagal membuat penjualan: ${response.statusCode} - ${response.body}',
  //       );
  //     }
  //   } catch (e) {
  //     throw Exception('Terjadi kesalahan: $e');
  //   }
  // }

  static Future<void> createSale(Transaction transaction) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/api/v1/sales');

    try {
      final response = await http.post(
        url,
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Authorization': token.toString(),
          'Content-Type': 'application/json',
        },
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 204) {
        // Tidak mengembalikan data, cukup selesai di sini
        return;
      } else {
        throw Exception(
          'Gagal membuat penjualan: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Tambahkan createPurchase jika belum ada
  static Future<Map<String, dynamic>> createPurchase(Map<String, dynamic> payload) async {
    // sesuaikan baseUrl/path dengan API Anda
    const baseUrl = 'https://your-api.example.com';
    final url = Uri.parse('$baseUrl/purchases');

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Create purchase failed: ${resp.statusCode} ${resp.body}');
    }
  }
}
