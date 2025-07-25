import 'package:flutter/material.dart';

class StokPage extends StatefulWidget {
  const StokPage({Key? key}) : super(key: key);

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  final _formKey = GlobalKey<FormState>();
  final _stokController = TextEditingController();

  String? selectedNama;
  String? selectedUkuran;
  String? selectedDistributor;

  List<Map<String, String>> barangMasuk = [];

  // List pilihan dropdown
  final List<String> namaProdukList = ['Air Mineral', 'Teh Botol', 'Kopi'];
  final List<String> ukuranList = ['250ml', '500ml', '1L'];
  final List<String> distributorList = ['Distributor A', 'Distributor B', 'Distributor C'];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        barangMasuk.insert(0, {
          'nama': selectedNama ?? '',
          'ukuran': selectedUkuran ?? '',
          'stok': _stokController.text,
          'distributor': selectedDistributor ?? '',
          'tanggal': DateTime.now().toString().substring(0, 16),
        });

        selectedNama = null;
        selectedUkuran = null;
        selectedDistributor = null;
        _stokController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00563B);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding = constraints.maxWidth > 600 ? 64 : 16;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildDropdown(
                        value: selectedNama,
                        label: 'Nama Produk',
                        icon: Icons.shopping_bag,
                        items: namaProdukList,
                        onChanged: (val) => setState(() => selectedNama = val),
                      ),
                      buildDropdown(
                        value: selectedUkuran,
                        label: 'Ukuran',
                        icon: Icons.straighten,
                        items: ukuranList,
                        onChanged: (val) => setState(() => selectedUkuran = val),
                      ),
                      buildInput(
                        controller: _stokController,
                        label: 'Stok',
                        icon: Icons.confirmation_number,
                        keyboardType: TextInputType.number,
                        iconColor: primaryColor,
                      ),
                      buildDropdown(
                        value: selectedDistributor,
                        label: 'Asal Distributor',
                        icon: Icons.local_shipping,
                        items: distributorList,
                        onChanged: (val) => setState(() => selectedDistributor = val),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Tambah Barang Masuk'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Riwayat Barang Masuk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: barangMasuk.isEmpty
                      ? const Center(child: Text('Belum ada barang masuk'))
                      : ListView.builder(
                          itemCount: barangMasuk.length,
                          itemBuilder: (context, index) {
                            final item = barangMasuk[index];
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Ukuran: ${item['ukuran']}', style: TextStyle(color: primaryColor)),
                                    Text('Stok: ${item['stok']}', style: TextStyle(color: primaryColor)),
                                    Text('Distributor: ${item['distributor']}', style: TextStyle(color: primaryColor)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          item['tanggal'] ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: primaryColor.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Color iconColor = const Color(0xFF00563B),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: iconColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }

  Widget buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    const Color primaryColor = Color(0xFF00563B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        isExpanded: true,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
      ),
    );
  }
}
