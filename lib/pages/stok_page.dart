import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/product_api.dart';
import 'package:flutter_toko_bahan_kue/api/distributor_api.dart';
import 'package:flutter_toko_bahan_kue/models/product_model.dart';
import 'package:flutter_toko_bahan_kue/models/distributor_model.dart';
import 'package:flutter_toko_bahan_kue/models/size_model.dart';
import '../api/sale_api.dart'; // <-- add this import

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Product>> productsFuture;
  late Future<List<Distributor>> distributorsFuture;
  Distributor? selectedDistributor;
  final List<Map<String, dynamic>> selectedProducts = [];
  final TextEditingController productSearchController = TextEditingController();
  final TextEditingController distributorSearchController =
      TextEditingController();
  List<Product> productSearchResults = [];
  List<Distributor> distributorSearchResults = [];

  @override
  void initState() {
    super.initState();
    productsFuture = ProductApi.fetchProductList("");
    distributorsFuture = DistributorApi.fetchDistributorList();
  }

  void addProduct(Product product) {
    setState(() {
      selectedProducts.add({
        'product': product,
        'size': null,
        'price': 0,
        'buy_price': 0, // <-- added buy_price
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

  void updateQuantity(int index, String value) {
    setState(() {
      selectedProducts[index]['quantity'] = int.tryParse(value) ?? 0;
    });
  }

  void handleProductSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        productSearchResults = [];
      });
      return;
    }
    try {
      final results = await ProductApi.fetchProductList(query);
      setState(() {
        productSearchResults = results.take(4).toList();
      });
    } catch (e) {
      setState(() {
        productSearchResults = [];
      });
    }
  }

  void handleDistributorSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        distributorSearchResults = [];
      });
      return;
    }
    try {
      final results = await DistributorApi.fetchDistributorList();
      setState(() {
        distributorSearchResults = results
            .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
            .take(4)
            .toList();
      });
    } catch (e) {
      setState(() {
        distributorSearchResults = [];
      });
    }
  }

  void selectDistributor(Distributor distributor) {
    setState(() {
      selectedDistributor = distributor;
      distributorSearchResults = [];
      distributorSearchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Manajemen Stok Barang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: const Color(0xFF00563B),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00563B).withOpacity(0.05),
                    const Color(0xFF00382A).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Distributor section with search
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Distributor search
                        SearchBar(
                          controller: distributorSearchController,
                          onSearch: handleDistributorSearch,
                          placeholder: 'Cari distributor...',
                          icon: Icons.local_shipping,
                        ),
                        const SizedBox(height: 12),
                        // Display selected distributor or empty state
                        if (selectedDistributor != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00563B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Distributor terpilih: ${selectedDistributor!.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00563B),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Color(0xFF00563B),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedDistributor = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        else
                          const Text(
                            'Belum memilih distributor',
                            style: TextStyle(color: Colors.grey),
                          ),
                        // Show search results if any
                        if (distributorSearchResults.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: distributorSearchResults.length,
                              itemBuilder: (context, index) {
                                final distributor =
                                    distributorSearchResults[index];
                                return DistributorResultItem(
                                  distributor: distributor,
                                  onTap: () => selectDistributor(distributor),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Product search section
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SearchBar(
                          controller: productSearchController,
                          onSearch: handleProductSearch,
                          placeholder: 'Cari produk...',
                          icon: Icons.search,
                        ),
                        const SizedBox(height: 12),
                        if (productSearchResults.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: productSearchResults.length,
                              itemBuilder: (context, index) {
                                final product = productSearchResults[index];
                                return SearchResultItem(
                                  product: product,
                                  onTap: () {
                                    addProduct(product);
                                    setState(() {
                                      productSearchResults = [];
                                      productSearchController.clear();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Selected products section
                if (selectedProducts.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daftar Produk Terpilih (${selectedProducts.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00563B),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => selectedProducts.clear()),
                            icon: const Icon(
                              Icons.clear_all,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Hapus Semua',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...selectedProducts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final product = item['product'] as Product;
                        final selectedSize = item['size'] as Size?;
                        return ProductCard(
                          product: product,
                          selectedSize: selectedSize,
                          quantity: item['quantity'],
                          buyPrice: item['buy_price'], // <-- pass buy price
                          onSizeChanged: (size) {
                            setState(() {
                              item['size'] = size;
                              item['price'] = size?.sellPrice ?? 0;
                              item['stock'] = size?.stock ?? 0;
                              // keep existing buy_price unless you want to override from size
                            });
                          },
                          onQuantityChanged: (value) =>
                              updateQuantity(index, value),
                          onBuyPriceChanged: (value) {
                            setState(() {
                              item['buy_price'] = int.tryParse(value) ?? 0;
                            });
                          },
                          onDelete: () => removeProduct(index),
                        );
                      }),
                    ],
                  ),
                const SizedBox(height: 30),
                // Save button
                ElevatedButton(
                  onPressed:
                      selectedDistributor == null || selectedProducts.isEmpty
                      ? null
                      : () async {
                          // Validasi data sebelum submit
                          final errors = <String>[];

                          if (selectedDistributor == null) {
                            errors.add('Pilih distributor terlebih dahulu');
                          }

                          for (var i = 0; i < selectedProducts.length; i++) {
                            final item = selectedProducts[i];
                            final product = item['product'] as Product;
                            final size = item['size'] as Size?;
                            final quantity = item['quantity'] as int? ?? 0;
                            final buyPrice = item['buy_price'] as int? ?? 0;

                            if (size == null) {
                              errors.add(
                                'Produk "${product.name}" belum memilih ukuran',
                              );
                            } else if (quantity <= 0) {
                              errors.add(
                                'Produk "${product.name}" jumlah harus lebih dari 0',
                              );
                            } else if (buyPrice <= 0) {
                              errors.add(
                                'Produk "${product.name}" harga beli harus lebih dari 0',
                              );
                            }
                          }

                          if (errors.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errors.join('\n')),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                            return;
                          }

                          // Persiapkan payload pembelian berdasarkan selectedProducts
                          final payload = {
                            'distributor_id': selectedDistributor!.id,
                            'items': selectedProducts.map((item) {
                              final size = item['size'] as Size;
                              return {
                                'branch_inventory_id': size.branchInventoryId,
                                'quantity': item['quantity'] as int,
                                'buy_price': item['buy_price'] as int,
                              };
                            }).toList(),
                          };

                          // Panggil API untuk membuat purchase (simpan riwayat pembelian)
                          try {
                            await SaleApi.createPurchase(payload);
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Stok & pembelian berhasil disimpan',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Reset lokal jika perlu
                            setState(() {
                              selectedProducts.clear();
                              selectedDistributor = null;
                              productSearchController.clear();
                              distributorSearchController.clear();
                              productSearchResults.clear();
                              distributorSearchResults.clear();
                            });

                            // Return true supaya SalePage mereload riwayat pembelian
                            if (!mounted) return;
                            Navigator.pop(context, true);
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menyimpan pembelian: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00563B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Simpan Perubahan Stok',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable search bar component
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String placeholder;
  final IconData icon;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.placeholder,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: Icon(icon, color: const Color(0xFF00563B)),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  controller.clear();
                  onSearch('');
                },
                icon: const Icon(Icons.close, color: Color(0xFF00563B)),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00563B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00563B), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: onSearch,
    );
  }
}

// Reusable search result item for distributors
class DistributorResultItem extends StatelessWidget {
  final Distributor distributor;
  final VoidCallback onTap;

  const DistributorResultItem({
    super.key,
    required this.distributor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF00563B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Color(0xFF00563B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      distributor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Alamat: ${distributor.address}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Color(0xFF00563B)),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable search result item for products
class SearchResultItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const SearchResultItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF00563B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2, color: Color(0xFF00563B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'SKU: ${product.sku}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      'Stok tersedia: ${product.sizes.first.stock}',
                      style: TextStyle(color: Colors.green[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_circle, color: Color(0xFF00563B)),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable product card
class ProductCard extends StatelessWidget {
  final Product product;
  final Size? selectedSize;
  final int quantity;
  final int buyPrice; // <-- added buyPrice
  final Function(Size?) onSizeChanged;
  final Function(String) onQuantityChanged;
  final Function(String) onBuyPriceChanged; // <-- callback for buy price
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.selectedSize,
    required this.quantity,
    required this.buyPrice,
    required this.onSizeChanged,
    required this.onQuantityChanged,
    required this.onBuyPriceChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00563B),
                    ),
                  ),
                ),
                Text(
                  'SKU: ${product.sku}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Size>(
              value: selectedSize,
              decoration: InputDecoration(
                labelText: 'Ukuran',
                labelStyle: const TextStyle(color: Color(0xFF00563B)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
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
              onChanged: onSizeChanged,
            ),
            const SizedBox(height: 12),
            if (selectedSize != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Harga: Rp ${selectedSize!.sellPrice}',
                      style: const TextStyle(color: Color(0xFF00563B)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Stok tersedia: ${selectedSize!.stock}',
                      style: const TextStyle(color: Color(0xFF00563B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // Harga Beli input
            TextFormField(
              initialValue: buyPrice.toString(),
              decoration: InputDecoration(
                labelText: 'Harga Beli (Rp)',
                labelStyle: const TextStyle(color: Color(0xFF00563B)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: onBuyPriceChanged,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: quantity.toString(),
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      labelStyle: TextStyle(color: Color(0xFF00563B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: onQuantityChanged,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00563B),
                    foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
                  ),
                  child: const Text('Hitung'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
