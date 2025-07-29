import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Map<String, dynamic>> cart;
  late List<int> quantities;
  double discount = 0;
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _namaPelangganController =
      TextEditingController();
  String paymentType = 'Tunai';
  final TextEditingController _uangCustomerController = TextEditingController();
  double uangCustomer = 0;
  double kembalian = 0;
  String paymentStatus = 'complete'; // default

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cart = List<Map<String, dynamic>>.from(
      ModalRoute.of(context)?.settings.arguments
              as List<Map<String, dynamic>>? ??
          [],
    );
    quantities = List<int>.filled(cart.length, 1);
  }

  double get totalPrice {
    double total = 0;
    for (int i = 0; i < cart.length; i++) {
      total += (cart[i]['price'] as int) * quantities[i];
    }
    return total;
  }

  double get finalPrice => (totalPrice - discount).clamp(0, double.infinity);

  void _updateDiscount(String value) {
    setState(() {
      discount = double.tryParse(value) ?? 0;
    });
  }

  void _updateUangCustomer(String value) {
    setState(() {
      uangCustomer = double.tryParse(value) ?? 0;
      kembalian = (uangCustomer - finalPrice).clamp(0, double.infinity);
    });
  }

  void _onSelesai() {
    if (cart.isEmpty) return;
    final transaksi = {
      'jenis': 'terjual',
      'namaPelanggan': _namaPelangganController.text,
      'produk': [
        for (int i = 0; i < cart.length; i++)
          {
            'name': cart[i]['name'] ?? cart[i]['nama'],
            'size': cart[i]['size'] ?? cart[i]['ukuran'],
            'jumlah': quantities[i],
            'price': cart[i]['price'],
          },
      ],
      'total': totalPrice,
      'diskon': discount,
      'totalAkhir': finalPrice,
      'jenisPembayaran': paymentType,
      'uangCustomer': uangCustomer,
      'kembalian': kembalian,
      'tanggal': DateTime.now().toString().substring(0, 16),
      'status': paymentStatus, // Tambahkan status
    };

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (paymentStatus == 'complete') {
        Navigator.pushNamed(context, '/riwayat', arguments: transaksi);
      } else {
        Navigator.pushNamed(context, '/pending', arguments: transaksi);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00563B);
    const Color cardBg = Color(0xFFF6F6F6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      backgroundColor: Colors.white, // <- background halaman putih
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding = constraints.maxWidth > 600 ? 64 : 16;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: cart.isEmpty
                ? const Center(child: Text('Keranjang kosong'))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Pelanggan
                        const Text(
                          'Nama Pelanggan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _namaPelangganController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan nama pelanggan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person_outline),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // List produk di keranjang
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cart.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return Card(
                              color: const Color(
                                0xFFE8F5E9,
                              ), // <- card hijau muda
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Ukuran: ${item['size']} | Harga: Rp${item['price']}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (quantities[index] > 1) {
                                              quantities[index]--;
                                            }
                                          });
                                        },
                                      ),
                                      Text(
                                        '${quantities[index]}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            quantities[index]++;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Hapus produk',
                                        onPressed: () {
                                          setState(() {
                                            cart.removeAt(index);
                                            quantities.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Diskon input
                        const Text(
                          'Diskon / Potongan Harga',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.discount_outlined),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onChanged: _updateDiscount,
                        ),

                        const SizedBox(height: 24),

                        // Rangkuman Total Harga
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildSummaryRow(
                                  'Total',
                                  'Rp${totalPrice.toStringAsFixed(0)}',
                                ),
                                _buildSummaryRow(
                                  'Potongan',
                                  '- Rp${discount.toStringAsFixed(0)}',
                                ),
                                const Divider(),
                                _buildSummaryRow(
                                  'Total Akhir',
                                  'Rp${finalPrice.toStringAsFixed(0)}',
                                  highlight: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Jenis Pembayaran
                        const Text(
                          'Jenis Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Tunai',
                              groupValue: paymentType,
                              onChanged: (val) {
                                setState(() {
                                  paymentType = val!;
                                });
                              },
                              activeColor: primaryColor,
                            ),
                            const Text('Tunai'),
                            Radio<String>(
                              value: 'Non Tunai',
                              groupValue: paymentType,
                              onChanged: (val) {
                                setState(() {
                                  paymentType = val!;
                                });
                              },
                              activeColor: primaryColor,
                            ),
                            const Text('Non Tunai'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Input uang customer
                        const Text(
                          'Jumlah Uang dari Customer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _uangCustomerController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.payments_outlined),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onChanged: _updateUangCustomer,
                        ),

                        const SizedBox(height: 12),

                        // Tampilkan kembalian
                        if (paymentType == 'Tunai')
                          _buildSummaryRow(
                            'Kembalian',
                            'Rp${kembalian.toStringAsFixed(0)}',
                            highlight: true,
                          ),

                        const SizedBox(height: 24),

                        // Status Pembayaran
                        const Text(
                          'Status Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'complete',
                              groupValue: paymentStatus,
                              onChanged: (val) {
                                setState(() {
                                  paymentStatus = val!;
                                });
                              },
                              activeColor: primaryColor,
                            ),
                            const Text('Complete'),
                            Radio<String>(
                              value: 'pending',
                              groupValue: paymentStatus,
                              onChanged: (val) {
                                setState(() {
                                  paymentStatus = val!;
                                });
                              },
                              activeColor: primaryColor,
                            ),
                            const Text('Pending'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Tombol Selesai
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _onSelesai,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Selesaikan Transaksi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: highlight ? 18 : 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 18 : 14,
              color: highlight ? Theme.of(context).colorScheme.primary : null,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
