import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Simpan token ke SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Ambil token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Hapus token dari SharedPreferences
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Periksa apakah pengguna sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
