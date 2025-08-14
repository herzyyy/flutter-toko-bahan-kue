import 'package:flutter/material.dart';
import '../data/cart_data.dart'; // Impor global cart dan quantities

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _initialized = false;

  double discount = 0;
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _namaPelangganController =
      TextEditingController();
  String paymentType = 'Tunai';
  final TextEditingController _uangCustomerController = TextEditingController();
  double uangCustomer = 0;
  double kembalian = 0;
  String paymentStatus = 'complete';

  final List<String> sizeOptions = ['250g', '500g', '1kg'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      for (var i = 0; i < globalCart.length; i++) {
        globalCart[i]['id'] ??=
            '${globalCart[i]['name']}_$i${DateTime.now().millisecondsSinceEpoch}';
      }

      if (globalQuantities.length < globalCart.length) {
        globalQuantities.addAll(
          List<int>.filled(globalCart.length - globalQuantities.length, 1),
        );
      }

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _namaPelangganController.dispose();
    _uangCustomerController.dispose();
    super.dispose();
  }

  void _ensureQuantitiesMatch() {
    if (globalQuantities.length < globalCart.length) {
      globalQuantities.addAll(
        List<int>.filled(globalCart.length - globalQuantities.length, 1),
      );
    } else if (globalQuantities.length > globalCart.length) {
      globalQuantities.removeRange(globalCart.length, globalQuantities.length);
    }
  }

  double get totalPrice {
    double total = 0;
    for (int i = 0; i < globalCart.length; i++) {
      final priceVal = globalCart[i]['price'] ?? 0;
      final price = (priceVal is num)
          ? priceVal.toDouble()
          : double.tryParse(priceVal.toString()) ?? 0;
      final qty = (i < globalQuantities.length) ? globalQuantities[i] : 1;
      total += price * qty;
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
    if (globalCart.isEmpty) return;
    final transaksi = {
      'jenis': 'terjual',
      'namaPelanggan': _namaPelangganController.text,
      'produk': [
        for (int i = 0; i < globalCart.length; i++)
          {
            'name': globalCart[i]['name'] ?? globalCart[i]['nama'],
            'size': globalCart[i]['size'] ?? '250g',
            'stock': globalCart[i]['stock'],
            'price': globalCart[i]['price'],
          },
      ],
      'total': totalPrice,
      'diskon': discount,
      'totalAkhir': finalPrice,
      'jenisPembayaran': paymentType,
      'uangCustomer': uangCustomer,
      'kembalian': kembalian,
      'tanggal': DateTime.now().toString().substring(0, 16),
      'status': paymentStatus,
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

  void _removeItemAt(int index) {
    if (index < 0 || index >= globalCart.length) return;
    setState(() {
      globalCart.removeAt(index);
      if (index < globalQuantities.length) globalQuantities.removeAt(index);
      _ensureQuantitiesMatch();
    });
  }

  void _updateQuantity(int index, int delta) {
    if (index < 0 || index >= globalCart.length) return;
    setState(() {
      if (index >= globalQuantities.length) _ensureQuantitiesMatch();
      final newQty = globalQuantities[index] + delta;
      if (newQty < 1) return;
      globalQuantities[index] = newQty;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00563B);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFFDFDFD),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding = constraints.maxWidth > 600 ? 64 : 16;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: globalCart.isEmpty
                ? const Center(child: Text('Keranjang kosong'))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Nama Pelanggan'),
                        _buildInputField(
                          controller: _namaPelangganController,
                          hintText: 'Masukkan nama pelanggan',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 24),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: globalCart.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _buildCartItem(index),
                        ),
                        const SizedBox(height: 24),

                        _buildSectionTitle('Diskon / Potongan Harga'),
                        _buildInputField(
                          controller: _discountController,
                          hintText: '0',
                          icon: Icons.discount_outlined,
                          onChanged: _updateDiscount,
                          isNumber: true,
                        ),
                        const SizedBox(height: 24),

                        _buildPriceSummary(),
                        const SizedBox(height: 24),

                        _buildSectionTitle('Jenis Pembayaran'),
                        _buildRadioOptions(
                          ['Tunai', 'Non Tunai'],
                          paymentType,
                          (val) {
                            setState(() => paymentType = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildSectionTitle('Jumlah Uang dari Customer'),
                        _buildInputField(
                          controller: _uangCustomerController,
                          hintText: '0',
                          icon: Icons.payments_outlined,
                          onChanged: _updateUangCustomer,
                          isNumber: true,
                        ),
                        const SizedBox(height: 12),

                        if (paymentType == 'Tunai')
                          _buildSummaryRow(
                            'Kembalian',
                            'Rp${kembalian.toStringAsFixed(0)}',
                            highlight: true,
                          ),
                        const SizedBox(height: 24),

                        _buildSectionTitle('Status Pembayaran'),
                        _buildRadioOptions(
                          ['complete', 'pending'],
                          paymentStatus,
                          (val) {
                            setState(() => paymentStatus = val);
                          },
                        ),
                        const SizedBox(height: 24),

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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isNumber = false,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildCartItem(int index) {
    final item = globalCart[index];
    return Card(
      key: ValueKey(item['id']),
      color: const Color(0xFFF1F8F5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['name'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Text('Ukuran: ', style: TextStyle(fontSize: 13)),
                    DropdownButton<String>(
                      value: item['size'],
                      items: sizeOptions
                          .map(
                            (size) => DropdownMenuItem(
                              value: size,
                              child: Text(size),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => item['size'] = val),
                      underline: const SizedBox(),
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                      dropdownColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rp${item['price'] ?? 0}',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _updateQuantity(index, -1),
                ),
                Text(
                  '${index < globalQuantities.length ? globalQuantities[index] : 1}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _updateQuantity(index, 1),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus produk',
                  onPressed: () => _removeItemAt(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow('Total', 'Rp${totalPrice.toStringAsFixed(0)}'),
            _buildSummaryRow('Potongan', '- Rp${discount.toStringAsFixed(0)}'),
            const Divider(),
            _buildSummaryRow(
              'Total Akhir',
              'Rp${finalPrice.toStringAsFixed(0)}',
              highlight: true,
            ),
          ],
        ),
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

  Widget _buildRadioOptions(
    List<String> options,
    String groupValue,
    Function(String) onChanged,
  ) {
    return Wrap(
      spacing: 16,
      children: options
          .map(
            (option) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: option,
                  groupValue: groupValue,
                  onChanged: (val) => onChanged(val!),
                  activeColor: const Color(0xFF00563B),
                ),
                Text(option),
              ],
            ),
          )
          .toList(),
    );
  }
}
