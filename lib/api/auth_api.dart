import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';
import 'package:flutter_toko_bahan_kue/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApi {
  static Future<User> current() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Token tidak tersedia, silakan login ulang.');
    }

    final response = await http.get(
      Uri.parse('https://top-gibbon-engaged.ngrok-free.app/gate/auth/me'),
      headers: {'ngrok-skip-browser-warning': 'true', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final userResponse = User.fromJson(jsonResponse['data']);
      return userResponse; // return tipe User
    } else {
      throw Exception('Gagal memuat user: ${response.body}');
    }
  }

  static Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://top-gibbon-engaged.ngrok-free.app/gate/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Asumsi response: {"token": "..."}
      return data['data']['token'] as String;
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  static Future<void> logout() async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('https://top-gibbon-engaged.ngrok-free.app/gate/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token.toString(),
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Logout gagal: ${response.body}');
    }
  }
}
