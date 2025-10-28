import 'package:flutter/material.dart';

class OpnamePage extends StatefulWidget {
  const OpnamePage({Key? key}) : super(key: key);

  @override
  State<OpnamePage> createState() => _OpnamePageState();
}

class _OpnamePageState extends State<OpnamePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> selectedProducts = [];

  final List<String> sizeOptions = ['250g', '500g', '1kg'];

  final List<Map<String, dynamic>> allProducts = [
    {'nama': 'Tepung Terigu', 'ukuran': '1kg', 'stok': 10},
    {'nama': 'Gula Pasir', 'ukuran': '500g', 'stok': 5},
    {'nama': 'Coklat Bubuk', 'ukuran': '250g', 'stok': 3},
  ];

  void _searchProduct(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = [];
      } else {
        searchResults = allProducts
            .where((p) => p['nama'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectProduct(Map<String, dynamic> product) {
    if (!selectedProducts.any(
      (p) => p['nama'] == product['nama'] && p['ukuran'] == product['ukuran'],
    )) {
      setState(() {
        final newProduct = Map<String, dynamic>.from(product);
        newProduct['ukuran'] = ''; // ukuran kosong
        newProduct['stok'] = ''; // stok kosong
        newProduct['note'] = ''; // <-- added note field
        selectedProducts.add(newProduct);
      });
    }
    _searchController.clear();
    searchResults = [];
  }

  void _updateStok() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stok barang berhasil diupdate!')),
    );
    setState(() {
      selectedProducts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00563B);
    const Color cardBg = Color(0xFFE8F5E9);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Opname Stok', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchProduct,
            ),
            const SizedBox(height: 10),
            if (searchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchResults.length,
                  itemBuilder: (context, i) {
                    final produk = searchResults[i];
                    return ListTile(
                      title: Text(produk['nama']),
                      subtitle: Text(
                        'Ukuran: ${produk['ukuran']} • Stok: ${produk['stok']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: primaryColor),
                        onPressed: () => _selectProduct(produk),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (selectedProducts.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: selectedProducts.length,
                  itemBuilder: (context, i) {
                    final produk = selectedProducts[i];
                    return Card(
                      color: cardBg,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        produk['nama'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    // Ukuran di kiri
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Ukuran',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          DropdownButtonFormField<String>(
                                            value: produk['ukuran'] == ''
                                                ? null
                                                : produk['ukuran'],
                                            hint: const Text('Pilih ukuran'),
                                            items: sizeOptions
                                                .map(
                                                  (size) => DropdownMenuItem(
                                                    value: size,
                                                    child: Text(size),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                produk['ukuran'] = val!;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 0,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: primaryColor,
                                            ),
                                            dropdownColor: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    // Stok di kanan
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Stok',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            initialValue: produk['stok']
                                                .toString(),
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 0,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                produk['stok'] = val;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                // Catatan / Note input (baru)
                                TextFormField(
                                  initialValue:
                                      produk['note']?.toString() ?? '',
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    labelText: 'Catatan (opsional)',
                                    alignLabelWithHint: true,
                                    hintText:
                                        'Tambahkan catatan untuk produk ini...',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      produk['note'] = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Tombol delete di pojok kanan atas
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 22,
                              ),
                              tooltip: 'Hapus produk',
                              onPressed: () {
                                setState(() {
                                  selectedProducts.removeAt(i);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (selectedProducts.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updateStok,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Update Stok'),
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
    );
  }
}
