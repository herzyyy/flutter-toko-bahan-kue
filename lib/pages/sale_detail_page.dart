import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/sale_api.dart';
import 'package:flutter_toko_bahan_kue/models/sale_detail_model.dart';
import 'package:intl/intl.dart';

class SaleDetailScreen extends StatefulWidget {
  final String saleCode;
  const SaleDetailScreen({Key? key, required this.saleCode}) : super(key: key);

  @override
  _SaleDetailScreenState createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  late Future<SaleDetail> _saleFuture;

  @override
  void initState() {
    super.initState();
    _saleFuture = SaleApi.getSaleDetails(widget.saleCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00563B),
        elevation: 0,
        title: const Text(
          'Detail Penjualan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<SaleDetail>(
        future: _saleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  ElevatedButton(
                    onPressed: () => setState(
                      () =>
                          _saleFuture = SaleApi.getSaleDetails(widget.saleCode),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final sale = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(sale),
                const SizedBox(height: 16),
                _buildProductSection(sale.items),
                const SizedBox(height: 16),
                _buildPaymentSection(sale.payments ?? []),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Card Informasi Transaksi
  Widget _buildInfoCard(SaleDetail sale) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header kode + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kode Transaksi: ${sale.code}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00563B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pelanggan: ${sale.customerName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(sale.createdAt)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  sale.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: sale.status == 'COMPLETED'
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Stat Box
          Row(
            children: [
              Flexible(
                child: _buildStatBox(
                  'Total Harga',
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(sale.total_price),
                  icon: Icons.attach_money,
                  iconColor: const Color(0xFF00563B),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: _buildStatBox(
                  'Total Barang',
                  '${sale.total_qty}',
                  icon: Icons.shopping_bag,
                  iconColor: const Color(0xFF00563B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Kotak Statistik
  Widget _buildStatBox(
    String label,
    String value, {
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00563B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Section Produk
  Widget _buildProductSection(List<Item> items) {
    return _buildCardSection(
      title: "Detail Produk",
      children: items.map((item) => _buildProductItem(item)).toList(),
    );
  }

  Widget _buildProductItem(Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF00563B),
                  ),
                ),
                Text(
                  '${item.sizeName} • Qty: ${item.quantity}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Text(
                  'Harga: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.price)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(item.quantity * item.price),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF00563B),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Section Pembayaran
  Widget _buildPaymentSection(List<Payment> payments) {
    if (payments.isEmpty) {
      return _buildCardSection(
        title: "Pembayaran",
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Belum ada pembayaran",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ),
        ],
      );
    }

    return _buildCardSection(
      title: "Pembayaran",
      children: payments.map((p) => _buildPaymentItem(p)).toList(),
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Metode: ${payment.method}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "Nominal: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(payment.amount)}",
          ),
          Text("Catatan: ${payment.note}"),
          Text(
            "Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(payment.createdAt)}",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Helper buat card section
  Widget _buildCardSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00563B),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
