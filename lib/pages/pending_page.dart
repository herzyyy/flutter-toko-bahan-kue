import 'package:flutter/material.dart';

class PendingPage extends StatefulWidget {
  const PendingPage({Key? key}) : super(key: key);

  @override
  State<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {
  static final List<Map<String, dynamic>> _pendingTransaksi = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final transaksi =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (transaksi != null && transaksi['status'] == 'pending') {
      final isDuplicate = _pendingTransaksi.any(
        (item) => item['tanggal'] == transaksi['tanggal'],
      );
      if (!isDuplicate) {
        _pendingTransaksi.insert(0, transaksi);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color highlight = Color(0xFF00563B);
    const Color textMain = Color(0xFF222222);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Status Pending',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: highlight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _pendingTransaksi.isEmpty
            ? Center(
                child: Text(
                  'Belum ada transaksi pending',
                  style: TextStyle(fontSize: 16, color: textMain),
                ),
              )
            : ListView.builder(
                itemCount: _pendingTransaksi.length,
                itemBuilder: (context, index) {
                  final transaksi = _pendingTransaksi[index];
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
                          Text(
                            transaksi['namaPelanggan']?.toString().isNotEmpty ==
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
                            transaksi['tanggal']?.toString().substring(0, 16) ??
                                '-',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Daftar Produk:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: highlight,
                            ),
                          ),
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
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
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
                          Text(
                            'Status: Pending',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
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
}
