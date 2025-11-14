import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/stock_opname_api.dart';
import 'package:flutter_toko_bahan_kue/models/product_model.dart';
import 'package:flutter_toko_bahan_kue/models/size_model.dart';

class StockOpnamePage extends StatefulWidget {
  const StockOpnamePage({super.key});

  @override
  State<StockOpnamePage> createState() => _StockOpnamePageState();
}

class _StockOpnamePageState extends State<StockOpnamePage> {
  List<Map<String, dynamic>> selectedProducts = [];
  TextEditingController productSearchController = TextEditingController();
  List<Product> productSearchResults = [];

  Future<void> searchProduct(String query) async {
    // TODO: Integrate API
    setState(() {
      productSearchResults = [];
    });
  }

  void addProduct(Product product) {
    setState(() {
      selectedProducts.add({
        "product": product,
        "size": null,
        "physical_qty": 0,
        "notes": "",
      });
    });
  }

  void removeProduct(int index) {
    setState(() {
      selectedProducts.removeAt(index);
    });
  }

  Future<void> submit() async {
    final details = selectedProducts.map((item) {
      final size = item["size"] as Size;
      return {
        "branch_inventory_id": size.branchInventoryId,
        "physical_qty": item["physical_qty"] ?? 0,
        "notes": item["notes"] ?? "",
      };
    }).toList();

    final payload = {"details": details};

    try {
      await StockOpnameApi.createStockOpname(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stock opname berhasil disimpan"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedProducts.clear();
        productSearchController.clear();
        productSearchResults.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Opname")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: productSearchController,
              decoration: const InputDecoration(labelText: "Cari produk"),
              onChanged: searchProduct,
            ),

            Expanded(
              child: ListView(
                children: [
                  ...selectedProducts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final product = item["product"] as Product;
                    final Size? selectedSize = item["size"];

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            DropdownButtonFormField<Size>(
                              value: selectedSize,
                              decoration: const InputDecoration(
                                labelText: "Pilih ukuran",
                              ),
                              items: product.sizes.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    "${s.name} (stok sistem: ${s.stock})",
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  item["size"] = val;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Stok fisik",
                              ),
                              onChanged: (v) {
                                setState(() {
                                  item["physical_qty"] = int.tryParse(v) ?? 0;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            TextField(
                              decoration: const InputDecoration(
                                labelText: "Catatan (opsional)",
                              ),
                              onChanged: (v) => item["notes"] = v,
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => removeProduct(index),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  "Hapus",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submit,
                child: const Text("Simpan Stock Opname"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
