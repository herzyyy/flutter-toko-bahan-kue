import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/debt_api.dart';
import 'package:flutter_toko_bahan_kue/api/debt_payment_api.dart';
import 'package:flutter_toko_bahan_kue/models/debt_detail_model.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/debt_api.dart';
import 'package:flutter_toko_bahan_kue/models/debt_detail_model.dart';
import 'package:intl/intl.dart';

class PendingDetailPage extends StatefulWidget {
  final int debtId;
  const PendingDetailPage({Key? key, required this.debtId}) : super(key: key);

  @override
  State<PendingDetailPage> createState() => _PendingDetailPageState();
}

class _PendingDetailPageState extends State<PendingDetailPage> {
  late Future<DebtDetail> _debtFuture;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController =
      TextEditingController(); // Tambahkan controller untuk note
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _debtFuture = DebtApi.getDebtDetail(widget.debtId);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose(); // Dispose controller note
    super.dispose();
  }

  Future<void> _makePayment() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Masukkan jumlah pembayaran')));
      return;
    }

    try {
      setState(() => _isLoading = true);

      final amount = int.parse(
        _amountController.text.replaceAll('.', ''),
      ); // Parse sebagai integer
      await DebtPaymentApi.createDebtPayment(
        widget.debtId,
        DebtPayment(
          id: 0,
          amount: amount,
          note: _noteController.text,
          paymentDate: DateTime.now(),
        ),
      ); // Kirim note juga

      // Refresh data setelah pembayaran
      setState(() {
        _debtFuture = DebtApi.getDebtDetail(widget.debtId);
        _amountController.clear();
        _noteController.clear(); // Clear note setelah pembayaran
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pembayaran berhasil!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal melakukan pembayaran: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF00563B), // Hijau tua
        elevation: 0,
        title: Text(
          'Detail Utang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DebtDetail>(
        future: _debtFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  ElevatedButton(
                    onPressed: () => setState(
                      () => _debtFuture = DebtApi.getDebtDetail(widget.debtId),
                    ),
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(child: Text('Data tidak ditemukan'));
          }

          final debt = snapshot.data!;
          final remainingAmount = debt.totalAmount - debt.paidAmount;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF00563B),
                        Color(0xFF4CAF50),
                      ], // Hijau gelap ke hijau terang
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Kode Referensi: ${debt.referenceCode}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              debt.status.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            ),
                            backgroundColor: debt.status == 'PAID'
                                ? Color.fromARGB(255, 2, 99, 68)
                                : Colors.orange,
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(debt.totalAmount)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dibayar: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(debt.paidAmount)}',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Jatuh Tempo: ${DateFormat('dd MMMM yyyy').format(debt.dueDate)}',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Remaining Amount Info
                if (remainingAmount > 0)
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFAED581), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sisa Pembayaran:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        Text(
                          'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(remainingAmount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Items Section
                SectionHeader(title: 'Barang yang Dibeli'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: debt.items.length,
                  itemBuilder: (context, index) {
                    final item = debt.items[index];
                    return ItemCard(item: item);
                  },
                ),

                // Payments Section
                SectionHeader(title: 'Riwayat Pembayaran'),
                if (debt.payments.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Color(0xFF757575),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF757575),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Anda belum melakukan pembayaran untuk utang ini.',
                            style: TextStyle(color: Color(0xFF9E9E9E)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: debt.payments.length,
                    itemBuilder: (context, index) {
                      final payment = debt.payments[index];
                      return PaymentCard(payment: payment);
                    },
                  ),

                // Payment Form Section
                if (remainingAmount > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Bayar Sekarang'),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Masukkan detail pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              SizedBox(height: 8),

                              // Field Jumlah Pembayaran
                              TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Jumlah Pembayaran',
                                  hintText: 'Rp...',
                                  prefixText: 'Rp',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () => _amountController.clear(),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  // Format angka dengan titik sebagai pemisah ribuan
                                  if (value.isNotEmpty) {
                                    final cleanValue = value.replaceAll(
                                      '.',
                                      '',
                                    );
                                    final formattedValue =
                                        NumberFormat.currency(
                                          locale: 'id',
                                          symbol: '',
                                          decimalDigits: 0,
                                        ).format(int.tryParse(cleanValue) ?? 0);
                                    if (formattedValue != value) {
                                      _amountController.value =
                                          TextEditingValue(
                                            text: formattedValue,
                                            selection: TextSelection.collapsed(
                                              offset: formattedValue.length,
                                            ),
                                          );
                                    }
                                  }
                                },
                              ),
                              SizedBox(height: 16),

                              // Field Catatan Pembayaran
                              TextField(
                                controller: _noteController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Catatan Pembayaran',
                                  hintText: 'Contoh: Pembayaran bulan Januari',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),

                              ElevatedButton(
                                onPressed: _isLoading ? null : _makePayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF00563B),
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text('Bayar Sekarang'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32), // Hijau tua
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;
  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xFFE8F5E9), // Hijau sangat terang
          child: Icon(
            Icons.shopping_bag,
            color: Color(0xFF2E7D32),
          ), // Hijau tua
        ),
        title: Text(
          item.productName,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.sizeName} • Qty: ${item.qty}'),
            Text(
              'Harga: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item.sellPrice * item.qty)}',
            ),
          ],
        ),
        trailing: Text(
          'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item.sellPrice)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32), // Hijau tua
          ),
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final DebtPayment payment;
  const PaymentCard({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xFFE8F5E9), // Hijau sangat terang
          child: Icon(Icons.payment, color: Color(0xFF2E7D32)), // Hijau tua
        ),
        title: Text(
          'Pembayaran #${payment.id}',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('dd MMMM yyyy HH:mm').format(payment.paymentDate),
        ),
        trailing: Text(
          'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(payment.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32), // Hijau tua
          ),
        ),
      ),
    );
  }
}
