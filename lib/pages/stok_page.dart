import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/product_api.dart';
import 'package:flutter_toko_bahan_kue/api/distributor_api.dart';
import 'package:flutter_toko_bahan_kue/models/product_model.dart';
import 'package:flutter_toko_bahan_kue/models/distributor_model.dart';
import 'package:flutter_toko_bahan_kue/models/size_model.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  late Future<List<Product>> products;
  late Future<List<Distributor>> distributors;
  Distributor? selectedDistributor;

  final List<Map<String, dynamic>> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    products = ProductApi.fetchProductList("");
    distributors = DistributorApi.fetchDistributorList();
  }

  void addProduct(Product product) {
    setState(() {
      selectedProducts.add({
        'product': product,
        'size': null,
        'price': 0,
        'stock': 0,
        'quantity': 0,
      });
    });
  }

  void removeProduct(int index) {
    setState(() {
      selectedProducts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tambah Stok'),
        backgroundColor: const Color(0xFF00563B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Distributor Dropdown
            FutureBuilder<List<Distributor>>(
              future: distributors,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Tidak ada distributor');
                }

                final distributorList = snapshot.data!;

                return DropdownButtonFormField<Distributor>(
                  value: selectedDistributor,
                  decoration: InputDecoration(
                    labelText: 'Asal Distributor',
                    prefixIcon: const Icon(
                      Icons.local_shipping,
                      color: Color(0xFF00563B),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  isExpanded: true,
                  items: distributorList
                      .map(
                        (d) => DropdownMenuItem(value: d, child: Text(d.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedDistributor = val),
                  validator: (v) => v == null ? 'Wajib dipilih' : null,
                );
              },
            ),
            const SizedBox(height: 16),

            // List produk yang dipilih
            ...selectedProducts.asMap().entries.map((entry) {
              final index = entry.key;
              final produk = entry.value;
              final product = produk['product'] as Product;
              final Size? selectedSize = produk['size'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama produk
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dropdown ukuran
                      DropdownButtonFormField<Size>(
                        value: selectedSize,
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
                        items: product.sizes
                            .map(
                              (size) => DropdownMenuItem<Size>(
                                value: size,
                                child: Text(
                                  "${size.name} - Rp ${size.sellPrice} (stok: ${size.stock})",
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            produk['size'] = val;
                            produk['price'] = val?.sellPrice ?? 0;
                            produk['stock'] = val?.stock ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // Harga & stok info
                      if (selectedSize != null) ...[
                        Text("Harga: Rp ${selectedSize.sellPrice}"),
                        Text("Stok tersedia: ${selectedSize.stock}"),
                      ],
                      const SizedBox(height: 8),

                      // Jumlah beli
                      TextFormField(
                        initialValue: produk['quantity'].toString(),
                        decoration: InputDecoration(
                          labelText: 'Jumlah',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            produk['quantity'] = int.tryParse(val) ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // Tombol hapus
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => removeProduct(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
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

            const SizedBox(height: 16),

            // Tombol tambah produk
            FutureBuilder<List<Product>>(
              future: products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Tidak ada produk');
                }

                final productList = snapshot.data!;

                return DropdownButtonFormField<Product>(
                  decoration: InputDecoration(
                    labelText: 'Tambah Produk',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: productList
                      .map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (product) {
                    if (product != null) {
                      addProduct(product);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Tombol simpan
            ElevatedButton.icon(
              onPressed: () {
                // TODO: submit ke API
                debugPrint("Distributor: ${selectedDistributor?.name}");
                debugPrint("Produk dipilih: $selectedProducts");
              },
              icon: const Icon(Icons.save),
              label: const Text("Simpan Stok"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00563B),
                foregroundColor: Colors.white,
                minimumSize: const ui.Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
