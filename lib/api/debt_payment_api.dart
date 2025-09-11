import 'dart:convert';
import 'package:flutter_toko_bahan_kue/models/debt_detail_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';

class DebtPaymentApi {
  static const String baseUrl =
      'https://top-gibbon-engaged.ngrok-free.app'; // ganti sesuai

  static Future<void> createDebtPayment(int id, DebtPayment debtPayment) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/api/v1/debt/$id/payments');

    try {
      final response = await http.post(
        url,
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Authorization': token.toString(),
          'Content-Type': 'application/json',
        },
        body: json.encode(debtPayment.toJson()),
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 204) {
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

  static Future<void> deleteDebtPayment(int debtID, int id) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/api/v1/debt/$debtID/payments/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Authorization': token.toString(),
        },
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 204) {
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
}
