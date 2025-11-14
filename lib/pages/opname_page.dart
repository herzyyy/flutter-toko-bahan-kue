// OpnamePage.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/product_api.dart';
import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';
import 'package:flutter_toko_bahan_kue/models/product_model.dart';
import 'package:http/http.dart' as http;

/// OpnamePage — full, integrated, no Provider
class OpnamePage extends StatefulWidget {
  const OpnamePage({Key? key}) : super(key: key);

  @override
  State<OpnamePage> createState() => _OpnamePageState();
}

class _OpnamePageState extends State<OpnamePage> {
  final TextEditingController _searchController = TextEditingController();

  // searchResults: each entry corresponds to one product-size combination
  // keys: sku, nama, branch_inventory_id, ukuran (size.name), stok (int)
  List<Map<String, dynamic>> searchResults = [];

  // selectedProducts contain items user wants to opname
  // keys: sku, nama, branch_inventory_id, ukuran, stok_system, physical_qty (string), note (string)
  List<Map<String, dynamic>> selectedProducts = [];

  bool isSearching = false;
  String? searchError;

  // debounce helper
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- SEARCH: call API and convert each product.size into separate item ---
  void _onSearchChanged(String q) {
    // simple debounce (300ms)
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _searchProduct(q),
    );
  }

  Future<void> _searchProduct(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        searchError = null;
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchError = null;
      searchResults = [];
    });

    try {
      final List<Product> products = await ProductApi.fetchProductList(query);

      final List<Map<String, dynamic>> flattened = [];
      for (final p in products) {
        for (final s in p.sizes) {
          flattened.add({
            'sku': p.sku,
            'nama': p.name,
            'branch_inventory_id': s.branchInventoryId,
            'ukuran': s.name,
            'stok': s.stock,
          });
        }
      }

      setState(() {
        searchResults = flattened;
      });
    } catch (e) {
      setState(() {
        searchError = 'Gagal mengambil produk: $e';
        searchResults = [];
      });
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  // select an item (sku+ukuran unique)
  void _selectProduct(Map<String, dynamic> item) {
    final exists = selectedProducts.any(
      (p) =>
          p['sku'] == item['sku'] &&
          p['branch_inventory_id'] == item['branch_inventory_id'],
    );

    if (!exists) {
      setState(() {
        selectedProducts.add({
          'sku': item['sku'],
          'nama': item['nama'],
          'branch_inventory_id': item['branch_inventory_id'],
          'ukuran': item['ukuran'],
          'stok_system': item['stok'],
          'physical_qty': item['stok'].toString(), // default to current stock
          'note': '',
        });
      });
    }

    _searchController.clear();
    setState(() => searchResults = []);
  }

  // remove selected
  void _removeSelected(int index) {
    setState(() {
      selectedProducts.removeAt(index);
    });
  }

  // build payload and send to API
  Future<void> _submitOpname() async {
    if (selectedProducts.isEmpty) return;

    // validate physical_qty numeric
    final errors = <String>[];
    for (final it in selectedProducts) {
      final val = it['physical_qty']?.toString() ?? '';
      if (val.isEmpty || int.tryParse(val) == null) {
        errors.add('${it['nama']} (${it['ukuran']}) : stok fisik tidak valid');
      }
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.join('\n')),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final details = selectedProducts.map((p) {
      return {
        'branch_inventory_id': p['branch_inventory_id'],
        'physical_qty': int.parse(p['physical_qty'].toString()),
        'notes': p['note']?.toString() ?? '',
      };
    }).toList();

    final payload = {'details': details};

    // call API
    try {
      await StockOpnameApi.createStockOpname(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock opname berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedProducts.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan opname: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // UI helpers
  Widget _buildSearchResults() {
    if (isSearching) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (searchError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(searchError!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (searchResults.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: kElevationToShadow[2],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: searchResults.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final r = searchResults[i];
          return ListTile(
            title: Text(r['nama'] ?? ''),
            subtitle: Text('Ukuran: ${r['ukuran']} • Stok: ${r['stok']}'),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle),
              color: const Color(0xFF00563B),
              onPressed: () => _selectProduct(r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedList() {
    if (selectedProducts.isEmpty) return const SizedBox.shrink();

    return Expanded(
      child: ListView.builder(
        itemCount: selectedProducts.length,
        itemBuilder: (context, idx) {
          final item = selectedProducts[idx];
          return Card(
            color: const Color(0xFFE8F5E9),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // header (name + delete)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['nama'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF00563B),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeSelected(idx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ukuran + stok system + stok fisik
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ukuran',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(item['ukuran'] ?? ''),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stok Sistem',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(item['stok_system']?.toString() ?? '0'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stok Fisik',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue:
                                  item['physical_qty']?.toString() ?? '',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (v) {
                                setState(() => item['physical_qty'] = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // note
                  TextFormField(
                    initialValue: item['note'] ?? '',
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => item['note'] = v),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00563B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opname Stok'),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
              // results
              _buildSearchResults(),
              const SizedBox(height: 12),

              // selected list
              _buildSelectedList(),

              // submit
              if (selectedProducts.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitOpname,
                    icon: const Icon(Icons.save),
                    label: const Text('Update Stok'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}

/// Simple API client to submit stock opname.
/// Adjust baseUrl / endpoint if your backend uses different path.
class StockOpnameApi {
  static const String baseUrl = ProductApi.baseUrl; // reuse same base url
  static Future<void> createStockOpname(Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse(
      '$baseUrl/api/v1/stock-opname',
    ); // <-- change if necessary

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token.toString(),
      },
      body: json.encode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Server error (${response.statusCode}): ${response.body}',
      );
    }
    // success
  }
}
