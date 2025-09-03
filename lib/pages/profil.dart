import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/auth_api.dart';
import 'package:flutter_toko_bahan_kue/models/user_model.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _sandiLamaController = TextEditingController();
  final TextEditingController _sandiBaruController = TextEditingController();
  final TextEditingController _konfirmasiSandiController =
      TextEditingController();

  late Future<User> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = AuthApi.current();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    }
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 18),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00563B)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Terjadi kesalahan: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Data user tidak ditemukan')),
          );
        }

        final user = snapshot.data!;
        _namaController.text = user.name;
        _alamatController.text = user.address;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            backgroundColor: const Color(0xFF00563B),
            elevation: 1,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildSectionTitle('Nama Pengguna'),
                  TextFormField(
                    controller: _namaController,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Nama tidak boleh kosong'
                        : null,
                    decoration: _inputDecoration('Masukkan nama lengkap'),
                  ),

                  _buildSectionTitle('Alamat'),
                  TextFormField(
                    controller: _alamatController,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Alamat tidak boleh kosong'
                        : null,
                    decoration: _inputDecoration(
                      'Masukkan alamat tempat tinggal',
                    ),
                  ),

                  const Divider(height: 40, thickness: 1),

                  _buildSectionTitle('Sandi Lama'),
                  TextFormField(
                    controller: _sandiLamaController,
                    obscureText: true,
                    decoration: _inputDecoration('Masukkan sandi lama'),
                  ),

                  _buildSectionTitle('Sandi Baru'),
                  TextFormField(
                    controller: _sandiBaruController,
                    obscureText: true,
                    decoration: _inputDecoration('Masukkan sandi baru'),
                    validator: (value) {
                      if (value != null && value.length < 6) {
                        return 'Sandi baru minimal 6 karakter';
                      }
                      return null;
                    },
                  ),

                  _buildSectionTitle('Konfirmasi Sandi Baru'),
                  TextFormField(
                    controller: _konfirmasiSandiController,
                    obscureText: true,
                    decoration: _inputDecoration('Ulangi sandi baru'),
                    validator: (value) {
                      if (value != _sandiBaruController.text) {
                        return 'Konfirmasi sandi tidak cocok';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _simpan,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Perubahan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00563B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
