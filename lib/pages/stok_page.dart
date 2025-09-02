import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/product_api.dart';
import 'package:flutter_toko_bahan_kue/models/product_model.dart';

class StokPage extends StatefulWidget {
  const StokPage({Key? key}) : super(key: key);

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedDistributor;

  final List<String> ukuranList = ['250ml', '500ml', '1L'];
  final List<String> distributorList = [
    'Distributor A',
    'Distributor B',
    'Distributor C',
  ];

  List<Map<String, dynamic>> produkStokList = [];
  final TextEditingController _produkSearchController = TextEditingController();
  List<Product> hasilPencarian = [];

  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    products = ProductApi.fetchProductList();
  }

  void _tambahProduk(Product produk) {
    setState(() {
      produkStokList.add({
        'sku': produk.sku,
        'name': produk.name,
        'size': null,
        'stock': 0,
        'price': 0,
      });
      _produkSearchController.clear();
      hasilPencarian.clear();
    });
  }

  void _filterProduk(String query) async {
    final allProducts = await products;
    final hasil = allProducts
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      hasilPencarian = hasil;
    });
  }

  void _eksekusiBarangMasuk() {
    if (selectedDistributor == null || selectedDistributor!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih distributor terlebih dahulu')),
      );
      return;
    }

    List<Map<String, dynamic>> produkMasuk = produkStokList
        .where((p) => p['stock'] > 0)
        .map(
          (p) => {
            'sku': p['sku'],
            'name': p['name'],
            'size': p['size'],
            'stock': p['stock'],
            'price': p['price'],
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

    Navigator.pushNamed(context, '/riwayat', arguments: barangMasukRiwayat);

    setState(() {
      produkStokList.clear();
      selectedDistributor = null;
      _produkSearchController.clear();
      hasilPencarian.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00563B);
    const Color cardColor = Color(0xFFF1F8F5);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _produkSearchController,
                decoration: InputDecoration(
                  hintText: 'Cari untuk menambahkan produk',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _filterProduk,
              ),
              if (hasilPencarian.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: hasilPencarian.length,
                  itemBuilder: (context, i) {
                    final produk = hasilPencarian[i];
                    return ListTile(
                      title: Text(produk.name),
                      trailing: const Icon(Icons.add),
                      onTap: () => _tambahProduk(produk),
                    );
                  },
                ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: produkStokList.length,
                  itemBuilder: (context, i) {
                    final produk = produkStokList[i];
                    return Card(
                      color: cardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  produk['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      produkStokList.removeAt(i);
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: produk['size'],
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              hint: const Text('Pilih ukuran'),
                              items: ukuranList
                                  .map(
                                    (ukuran) => DropdownMenuItem(
                                      value: ukuran,
                                      child: Text(ukuran),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  produk['size'] = val;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Harga'),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        initialValue:
                                            produk['price']?.toString() ?? '',
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          prefixText: 'Rp ',
                                          hintText: '0',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            produk['price'] =
                                                int.tryParse(val) ?? 0;
                                          });
                                        },
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
                                      const Text('Stok'),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        initialValue: produk['stock']
                                            .toString(),
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            produk['stock'] =
                                                int.tryParse(val) ?? 0;
                                          });
                                        },
                                      ),
                                    ],
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
          filled: true,
          fillColor: Colors.white,
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
