import 'package:flutter/material.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({Key? key}) : super(key: key);

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  static final List<Map<String, dynamic>> _riwayatTransaksi = [];
  bool _isReversed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final transaksi =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (transaksi != null && transaksi.containsKey('tanggal')) {
      final isDuplicate = _riwayatTransaksi.any(
        (item) => item['tanggal'] == transaksi['tanggal'],
      );
      if (!isDuplicate) {
        _riwayatTransaksi.insert(0, transaksi);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color highlight = Color(0xFF00563B);
    const Color textMain = Color(0xFF222222);
    const Color textSub = Color(0xFF4F4F4F);

    final transaksiList = _isReversed
        ? _riwayatTransaksi.reversed.toList()
        : _riwayatTransaksi;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: highlight,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert, color: Colors.white),
            tooltip: 'Urutkan',
            onPressed: () {
              setState(() {
                _isReversed = !_isReversed;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: transaksiList.isEmpty
            ? Center(
                child: Text(
                  'Belum ada transaksi',
                  style: TextStyle(fontSize: 16, color: textMain),
                ),
              )
            : ListView.builder(
                itemCount: transaksiList.length,
                itemBuilder: (context, index) {
                  final transaksi = transaksiList[index];
                  final List produk = transaksi['produk'] ?? [];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Nama dan Tanggal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                transaksi['namaPelanggan']
                                            ?.toString()
                                            .isNotEmpty ==
                                        true
                                    ? transaksi['namaPelanggan']
                                    : 'Tanpa Nama',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: highlight,
                                ),
                              ),
                              Text(
                                transaksi['tanggal']?.toString().substring(
                                      0,
                                      16,
                                    ) ??
                                    '-',
                                style: const TextStyle(
                                  color: textSub,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          /// Daftar Produk
                          const Text(
                            'Daftar Produk:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: highlight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...produk.map<Widget>((item) {
                            final name = item['name'] ?? '';
                            final size = item['size'] ?? '';
                            final jumlah = item['jumlah'] ?? 0;
                            final price = item['price'] ?? 0;
                            final total = price * jumlah;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$name ($size) x$jumlah',
                                      style: const TextStyle(color: textSub),
                                    ),
                                  ),
                                  Text(
                                    'Rp$total',
                                    style: const TextStyle(color: textMain),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const Divider(height: 24, color: highlight),

                          /// Total
                          buildInfoRow(
                            'Total:',
                            transaksi['total'],
                            highlight,
                            isBold: true,
                          ),

                          /// Diskon
                          buildInfoRow(
                            'Pengurangan:',
                            transaksi['diskon'],
                            highlight,
                            isMinus: true,
                          ),

                          /// Total Akhir
                          buildInfoRow(
                            'Total Akhir:',
                            transaksi['totalAkhir'],
                            highlight,
                            isBold: true,
                            isHighlight: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
    final String text = value is num
        ? '${isMinus ? '- ' : ''}Rp${value.toStringAsFixed(0)}'
        : 'Rp0';

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
}
