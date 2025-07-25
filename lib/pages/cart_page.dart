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

  void _onSelesai() {
    if (cart.isEmpty) return;
    final transaksi = {
      'namaPelanggan': _namaPelangganController.text,
      'produk': [
        for (int i = 0; i < cart.length; i++)
          {...cart[i], 'jumlah': quantities[i]},
      ],
      'total': totalPrice,
      'diskon': discount,
      'totalAkhir': finalPrice,
      'tanggal': DateTime.now().toIso8601String(),
    };

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushNamed(context, '/riwayat', arguments: transaksi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Keranjang',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00563B), // opsional sesuai tema
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                        TextField(
                          controller: _namaPelangganController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Pelanggan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
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
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                title: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Ukuran: ${item['size']} | Harga: Rp${item['price']}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
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
                                          Icons.add_circle_outline),
                                      onPressed: () {
                                        setState(() {
                                          quantities[index]++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Diskon input
                        TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Diskon / Potongan Harga (Rp)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.discount_outlined),
                          ),
                          onChanged: _updateDiscount,
                        ),

                        const SizedBox(height: 24),

                        // Rangkuman Total Harga
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildSummaryRow(
                                    'Total', 'Rp${totalPrice.toStringAsFixed(0)}'),
                                _buildSummaryRow('Potongan',
                                    '- Rp${discount.toStringAsFixed(0)}'),
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

                        // Tombol Selesai
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _onSelesai,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Selesaikan Transaksi'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
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
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: highlight ? 18 : 14,
                fontWeight:
                    highlight ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontSize: highlight ? 18 : 14,
                color: highlight
                    ? Theme.of(context).colorScheme.primary
                    : null,
                fontWeight:
                    highlight ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}
