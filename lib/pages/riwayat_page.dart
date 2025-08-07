import 'package:flutter/material.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({Key? key}) : super(key: key);

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  static final List<Map<String, dynamic>> _riwayatTransaksi = [];
  static final List<Map<String, dynamic>> _riwayatBarangMasuk = [];
  int _selectedTab = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final transaksi = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (transaksi != null && transaksi.containsKey('jenis')) {
      if (transaksi['jenis'] == 'masuk') {
        final isDuplicate = _riwayatBarangMasuk.any((item) => item['tanggal'] == transaksi['tanggal']);
        if (!isDuplicate) _riwayatBarangMasuk.insert(0, transaksi);
      } else {
        final isDuplicate = _riwayatTransaksi.any((item) => item['tanggal'] == transaksi['tanggal']);
        if (!isDuplicate) _riwayatTransaksi.insert(0, transaksi);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color highlight = Color(0xFF00563B);
    const Color cardColor = Color(0xFFF1F8F5);
    const Color textMain = Color(0xFF222222);
    const Color textSub = Color(0xFF4F4F4F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: highlight,
        elevation: 3,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.history, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Riwayat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: highlight,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton(
                  icon: Icons.receipt_long,
                  label: 'Transaksi',
                  selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                const SizedBox(width: 32),
                _buildTabButton(
                  icon: Icons.inventory_2,
                  label: 'Barang Masuk',
                  selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _selectedTab == 0
            ? (_riwayatTransaksi.isEmpty
                ? Center(child: Text('Belum ada transaksi', style: TextStyle(fontSize: 16, color: textMain)))
                : ListView.builder(
                    itemCount: _riwayatTransaksi.length,
                    itemBuilder: (context, index) {
                      final transaksi = _riwayatTransaksi[index];
                      final List produk = transaksi['produk'] ?? [];

                      return Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person, color: highlight, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        transaksi['namaPelanggan']?.toString().isNotEmpty == true
                                            ? transaksi['namaPelanggan']
                                            : 'Tanpa Nama',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: highlight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: textSub, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        transaksi['tanggal']?.toString().substring(0, 16) ?? '-',
                                        style: const TextStyle(color: textSub, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                decoration: BoxDecoration(
                                  color: highlight.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Daftar Produk',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: highlight,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...produk.map<Widget>((item) {
                                      final name = item['name'] ?? '';
                                      final size = item['size'] ?? '';
                                      final jumlah = item['jumlah'] ?? 0;
                                      final price = item['price'] ?? 0;
                                      final total = price * jumlah;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('$name ($size) x$jumlah',
                                                style: const TextStyle(color: textSub, fontSize: 14)),
                                            Text('Rp$total',
                                                style: const TextStyle(
                                                    color: highlight,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Divider(height: 24, color: highlight.withOpacity(0.4)),
                              buildInfoRow('Total:', transaksi['total'], highlight, isBold: true),
                              buildInfoRow('Pengurangan:', transaksi['diskon'], highlight, isMinus: true),
                              buildInfoRow('Total Akhir:', transaksi['totalAkhir'], highlight,
                                  isBold: true, isHighlight: true),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.payment, color: highlight, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    transaksi['jenisPembayaran'] == 'Tunai' ? 'Tunai' : 'Non Tunai',
                                    style: const TextStyle(
                                      color: highlight,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              if (transaksi['uangCustomer'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.attach_money, color: highlight, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Uang Customer: Rp${(transaksi['uangCustomer'] as num).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: highlight,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (transaksi['kembalian'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.money_off, color: highlight, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Kembalian: Rp${(transaksi['kembalian'] as num).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: highlight,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }))
            : (_riwayatBarangMasuk.isEmpty
                ? Center(child: Text('Belum ada barang masuk', style: TextStyle(fontSize: 16, color: textMain)))
                : ListView.builder(
                    itemCount: _riwayatBarangMasuk.length,
                    itemBuilder: (context, index) {
                      final riwayat = _riwayatBarangMasuk[index];
                      final produkList = riwayat['produk'] as List<dynamic>? ?? [];

                      return Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_shipping, color: highlight, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Distributor: ${riwayat['distributor'] ?? '-'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: highlight,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: textSub, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    riwayat['tanggal'] ?? '-',
                                    style: const TextStyle(color: textSub, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: highlight.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Produk Masuk',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: highlight,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ...produkList.map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${item['nama']} (${item['ukuran']}) x${item['stok']}',
                                              style: const TextStyle(color: textSub, fontSize: 14),
                                            ),
                                            Text(
                                              'Rp${item['harga'] ?? 0}',
                                              style: const TextStyle(
                                                color: highlight,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Total Harga',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: highlight,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          'Rp${produkList.fold<int>(0, (sum, item) => sum + ((item['harga'] ?? 0) as int) * ((item['stok'] ?? 0) as int))}',
                                          style: const TextStyle(
                                            color: highlight,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })),
      ),
    );
  }

  Widget buildInfoRow(
    String label,
    dynamic value,
    Color color, {
    bool isBold = false,
    bool isMinus = false,
    bool isHighlight = false,
  }) {
    String text;
    if (value is num) {
      text = '${isMinus ? '- ' : ''}Rp${value.toStringAsFixed(0)}';
    } else if (value is String) {
      text = value;
    } else {
      text = value?.toString() ?? '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlight ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          if (selected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 24,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
