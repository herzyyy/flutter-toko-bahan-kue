import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/distributor_model.dart';

class DistributorApi {
  static const String baseUrl = 'http://localhost:9090'; // ganti sesuai API

  static Future<List<Distributor>> fetchDistributorList() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/distributors'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Authorization': token.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];

      return data.map((e) => Distributor.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat distributor');
    }
  }
}
