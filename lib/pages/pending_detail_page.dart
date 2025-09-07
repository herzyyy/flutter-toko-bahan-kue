// screens/debt_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/debt_api.dart';
import 'package:flutter_toko_bahan_kue/models/debt_detail_model.dart';
import 'package:intl/intl.dart';

class PendingDetailScreen extends StatefulWidget {
  final int debtId;

  const PendingDetailScreen({Key? key, required this.debtId}) : super(key: key);

  @override
  _PendingDetailScreenState createState() => _PendingDetailScreenState();
}

class _PendingDetailScreenState extends State<PendingDetailScreen> {
  late Future<DebtDetail> _debtFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _debtFuture = DebtApi.getDebtDetail(widget.debtId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
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
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurpleAccent, Colors.purple],
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
                          Text(
                            'Kode Referensi: ${debt.referenceCode}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Chip(
                            label: Text(
                              debt.status.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            ),
                            backgroundColor: debt.status == 'PAID'
                                ? Colors.green
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
                SectionHeader(title: 'Pembayaran'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: debt.payments.length,
                  itemBuilder: (context, index) {
                    final payment = debt.payments[index];
                    return PaymentCard(payment: payment);
                  },
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
          color: Colors.deepPurpleAccent,
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
          backgroundColor: Colors.deepPurple.shade100,
          child: Icon(Icons.shopping_bag, color: Colors.deepPurple),
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
            color: Colors.deepPurple,
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
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.payment, color: Colors.green),
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }
}
