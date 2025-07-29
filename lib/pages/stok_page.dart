import 'package:flutter/material.dart';

class StokPage extends StatefulWidget {
  const StokPage({Key? key}) : super(key: key);

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedDistributor;

  // List produk
  final List<String> namaProdukList = ['Air Mineral', 'Teh Botol', 'Kopi'];
  final List<String> ukuranList = ['250ml', '500ml', '1L'];
  final List<String> distributorList = [
    'Distributor A',
    'Distributor B',
    'Distributor C',
  ];

  // List stok produk yang bisa diubah
  late List<Map<String, dynamic>> produkStokList;

  @override
  void initState() {
    super.initState();
    produkStokList = List.generate(
      namaProdukList.length,
      (i) => {
        'nama': namaProdukList[i],
        'ukuran': ukuranList[i % ukuranList.length],
        'stok': 0,
      },
    );
  }

  void _eksekusiBarangMasuk() {
    if (selectedDistributor == null || selectedDistributor!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih distributor terlebih dahulu')),
      );
      return;
    }
    List<Map<String, dynamic>> produkMasuk = produkStokList
        .where((p) => p['stok'] > 0)
        .map(
          (p) => {
            'nama': p['nama'],
            'ukuran': p['ukuran'],
            'stok': p['stok'],
            'harga': p['harga'], // tambahkan harga
          },
        )
        .toList();

    if (produkMasuk.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan stok pada minimal satu produk')),
      );
      return;
    }

    final barangMasukRiwayat = {
      'jenis': 'masuk',
      'distributor': selectedDistributor,
      'tanggal': DateTime.now().toString().substring(0, 16),
      'produk': produkMasuk,
    };

    // Kirim ke halaman riwayat
    Navigator.pushNamed(context, '/riwayat', arguments: barangMasukRiwayat);

    setState(() {
      for (var produk in produkStokList) {
        produk['stok'] = 0;
      }
      selectedDistributor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00563B);
    const Color cardBg = Color(0xFFF6F6F6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        title: Row(
          children: [
            const Icon(Icons.inventory, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Stok Barang Masuk',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Produk List (scrollable only)
              Expanded(
                child: ListView.builder(
                  itemCount: produkStokList.length,
                  itemBuilder: (context, i) {
                    final produk = produkStokList[i];
                    return Card(
                      color: const Color(0xFFE8F5E9), // hijau muda
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        produk['nama'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Ukuran: ${produk['ukuran']}',
                                          style: const TextStyle(
                                            color: primaryColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Harga',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              height: 40,
                                              child: TextFormField(
                                                initialValue:
                                                    produk['harga']
                                                        ?.toString() ??
                                                    '',
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: '0',
                                                  prefixText: 'Rp',
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    produk['harga'] =
                                                        int.tryParse(val) ?? 0;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Stok',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              height: 40,
                                              child: TextFormField(
                                                initialValue: produk['stok']
                                                    .toString(),
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: '0',
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    produk['stok'] =
                                                        int.tryParse(val) ?? 0;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Form distributor & tombol eksekusi (fixed)
              buildDropdown(
                value: selectedDistributor,
                label: 'Asal Distributor',
                icon: Icons.local_shipping,
                items: distributorList,
                onChanged: (val) => setState(() => selectedDistributor = val),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _eksekusiBarangMasuk,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Eksekusi Barang Masuk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
      ),
    );
  }
}
