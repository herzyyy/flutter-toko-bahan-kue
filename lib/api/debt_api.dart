import 'dart:convert';
import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';
import 'package:flutter_toko_bahan_kue/models/debt_detail_model.dart';
import 'package:http/http.dart' as http;
import '../models/debt_model.dart';

class DebtApi {
  static const String baseUrl = 'https://top-gibbon-engaged.ngrok-free.app';

  static Future<List<Debt>> fetchDebts(String status) async {
    final token = await AuthService.getToken();

    final url = Uri.parse(
      "$baseUrl/api/v1/debt?reference_type=SALE&status=$status",
    );
    final response = await http.get(
      url,
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['data'];
      return list.map((e) => Debt.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load debts: ${response.statusCode}");
    }
  }

  static Future<DebtDetail> getDebtDetail(int debtId) async {
    final token = await AuthService.getToken();

    final url = Uri.parse('$baseUrl/api/v1/debt/$debtId');

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
        return DebtDetail.fromJson(jsonData['data']);
      } else {
        throw Exception('Gagal memuat data utang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
