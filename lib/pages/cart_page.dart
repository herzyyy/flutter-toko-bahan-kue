import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/sale_api.dart';
import 'package:flutter_toko_bahan_kue/data/cart_data.dart';
import 'package:flutter_toko_bahan_kue/models/sale_create_model.dart';
import '../models/size_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController(); // Ubah nama controller
  final TextEditingController _paymentNoteController =
      TextEditingController(); // Tambah controller baru
  final TextEditingController _debtAmountController = TextEditingController();
  final TextEditingController _debtDueDateController = TextEditingController();
  final TextEditingController _paymentMethodController =
      TextEditingController();

  bool _isDebtMode = false;
  bool _isAddingPayment = false;
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _customerNameController.text = '';
    _paymentMethodController.text = 'TRANSFER';
  }

  void _addPayment() {
    setState(() {
      _isAddingPayment = true;
    });
  }

  void _savePayment() {
    if (_paymentAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal pembayaran')),
      );
      return;
    }

    if (_paymentMethodController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih metode pembayaran')));
      return;
    }

    setState(() {
      _payments.add({
        'method': _paymentMethodController.text.toUpperCase(),
        'amount':
            double.tryParse(
              _paymentAmountController.text.replaceAll(',', ''),
            ) ??
            0,
        'note': _paymentNoteController.text, // Gunakan controller baru
      });

      _paymentAmountController.clear(); // Bersihkan controller nominal
      _paymentNoteController.clear(); // Bersihkan controller catatan
      _isAddingPayment = false;
    });
  }

  void _removePayment(int index) {
    setState(() {
      _payments.removeAt(index);
    });
  }

  void _submitOrder() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Gabungkan item berdasarkan size_id
        final Map<int, int> mergedDetails = {};
        for (var i = 0; i < globalCart.length; i++) {
          final item = globalCart[i];
          final sizeId = item['size_id'] as int;
          final qty = globalQuantities[i];

          if (mergedDetails.containsKey(sizeId)) {
            mergedDetails[sizeId] = mergedDetails[sizeId]! + qty;
          } else {
            mergedDetails[sizeId] = qty;
          }
        }

        // Gabungkan pembayaran berdasarkan method
        final Map<String, double> mergedPayments = {};
        final Map<String, String> mergedNotes =
            {}; // kalau ada catatan, ambil yang terakhir

        for (var p in _payments) {
          final method = (p['method'] as String).toUpperCase();
          final amount = (p['amount'] as double?) ?? 0;
          final note = (p['note'] as String?) ?? '';

          if (mergedPayments.containsKey(method)) {
            mergedPayments[method] = mergedPayments[method]! + amount;
            mergedNotes[method] = note; // replace dengan note terakhir
          } else {
            mergedPayments[method] = amount;
            mergedNotes[method] = note;
          }
        }

        final transaction = Transaction(
          customerName: _customerNameController.text,
          details: mergedDetails.entries
              .map((e) => TransactionDetail(sizeId: e.key, qty: e.value))
              .toList(),
          payments: mergedPayments.isNotEmpty
              ? mergedPayments.entries
                    .map(
                      (e) => PaymentMethod(
                        method: e.key,
                        amount: e.value,
                        note: mergedNotes[e.key] ?? '',
                      ),
                    )
                    .toList()
              : null,
          debt: _isDebtMode
              ? DebtInfo(
                  dueDate: _debtDueDateController.text,
                  payments: [
                    DebtPayment(
                      amount: double.parse(_debtAmountController.text),
                    ),
                  ],
                )
              : null,
        );

        // Kirim transaksi ke backend
        await SaleApi.createSale(transaction);

        // Reset keranjang & pembayaran
        globalCart.clear();
        globalQuantities.clear();
        _payments.clear();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil disimpan!')),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan pesanan: $e')));
      }
    }
  }

  void _incrementQuantity(int index) {
    if (globalQuantities[index] < 10) {
      setState(() {
        globalQuantities[index]++;
      });
    }
  }

  void _decrementQuantity(int index) {
    if (globalQuantities[index] > 1) {
      setState(() {
        globalQuantities[index]--;
      });
    }
  }

  void _changeSize(int index) {
    final item = globalCart[index];
    final sizes = item['sizes'] as List<Size>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Ukuran Produk'),
        content: SingleChildScrollView(
          child: ListBody(
            children: sizes.map((size) {
              return RadioListTile<int>(
                title: Text(
                  '${size.name} • Rp ${size.sellPrice} • Stok: ${size.stock}',
                ),
                value: size.id,
                groupValue: item['size_id'],
                onChanged: (value) {
                  setState(() {
                    globalCart[index]['size_id'] = size.id;
                    globalCart[index]['size_name'] = size.name;
                    globalCart[index]['price'] = size.sellPrice;
                    globalCart[index]['stock'] = size.stock;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00563B),
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Pelanggan
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pelanggan',
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama pelanggan wajib diisi';
                    }
                    return null;
                  },
                ),
              ),

              // Daftar Pesanan
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Pesanan:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Divider(thickness: 1, height: 20),
                    ...globalCart.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${item['size_name']} • Rp ${item['price']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Qty: ${globalQuantities[index]}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 24,
                                      ),
                                      onPressed: () =>
                                          _decrementQuantity(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        size: 24,
                                      ),
                                      onPressed: () =>
                                          _incrementQuantity(index),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.change_circle_outlined,
                                    size: 24,
                                  ),
                                  onPressed: () => _changeSize(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Metode Pembayaran
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Divider(thickness: 1, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text(
                              'Bayar Tunai',
                              style: TextStyle(fontSize: 16),
                            ),
                            value: false,
                            groupValue: _isDebtMode,
                            activeColor: Color(0xFF00563B),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _isDebtMode = value;
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text(
                              'Hutang',
                              style: TextStyle(fontSize: 16),
                            ),
                            value: true,
                            groupValue: _isDebtMode,
                            activeColor: Color(0xFF00563B),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _isDebtMode = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (!_isDebtMode) ...[
                // Bagian Pembayaran Tunai
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pembayaran:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          FloatingActionButton(
                            mini: true,
                            backgroundColor: Color(0xFF00563B),
                            onPressed: _addPayment,
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, height: 20),

                      if (_isAddingPayment)
                        Column(
                          children: [
                            // Input Metode Pembayaran Baru
                            DropdownButtonFormField<String>(
                              value: _paymentMethodController.text,
                              items: ['TRANSFER', 'CASH', 'QRIS', 'DEBIT']
                                  .map(
                                    (method) => DropdownMenuItem(
                                      value: method,
                                      child: Text(method),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _paymentMethodController.text = value;
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Metode Pembayaran',
                                labelStyle: const TextStyle(fontSize: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Metode pembayaran wajib dipilih';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Input Nominal Pembayaran
                            TextFormField(
                              controller: _paymentAmountController,
                              decoration: InputDecoration(
                                labelText: 'Nominal Pembayaran',
                                labelStyle: const TextStyle(fontSize: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nominal wajib diisi';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Input Catatan Pembayaran
                            TextFormField(
                              controller: _paymentNoteController,
                              decoration: InputDecoration(
                                labelText: 'Catatan Pembayaran',
                                labelStyle: const TextStyle(fontSize: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _savePayment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00563B),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Simpan Pembayaran'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _isAddingPayment = false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Batalkan'),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            ..._payments.asMap().entries.map((entry) {
                              final index = entry.key;
                              final payment = entry.value;
                              return Dismissible(
                                key: Key('$index'),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _removePayment(index),
                                background: Container(
                                  color: Colors.red[100],
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                                child: Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    title: Text(
                                      payment['note'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Rp ${payment['amount'].toStringAsFixed(0)} (${payment['method']})',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                    ],
                  ),
                ),
              ] else ...[
                // Bagian Hutang
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Hutang:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(thickness: 1, height: 20),
                      TextFormField(
                        controller: _debtDueDateController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Jatuh Tempo',
                          labelStyle: const TextStyle(fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tanggal jatuh tempo wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _debtAmountController,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Angsuran',
                          labelStyle: const TextStyle(fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah angsuran wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Tombol Konfirmasi
              Container(
                margin: const EdgeInsets.only(top: 32),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00563B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Konfirmasi Pesanan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
