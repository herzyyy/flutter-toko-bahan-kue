import 'package:flutter/material.dart';

class PendingPage extends StatefulWidget {
  const PendingPage({Key? key}) : super(key: key);

  @override
  State<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {
  static final List<Map<String, dynamic>> _pendingTransaksi = [];
  static final List<Map<String, dynamic>> _completeTransaksi = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final transaksi =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (transaksi != null && transaksi['status'] == 'pending') {
      final List produk = transaksi['produk'] ?? [];
      double total = 0;
      for (var p in produk) {
        total += (p['price'] ?? 0) * (p['jumlah'] ?? 0);
      }
      transaksi['totalHutang'] = total;

      final isDuplicate = _pendingTransaksi.any(
        (item) => item['kdTransaksi'] == transaksi['kdTransaksi'],
      );
      if (!isDuplicate) {
        _pendingTransaksi.insert(0, transaksi);
      }
    }
  }

  Widget _buildList(List<Map<String, dynamic>> transaksiList, String status) {
    const Color highlight = Color(0xFF00563B);
    const Color cardColor = Color(0xFFF1F8F5);
    const Color textMain = Color(0xFF222222);

    if (transaksiList.isEmpty) {
      return Center(
        child: Text(
          status == 'pending'
              ? 'Belum ada transaksi pending'
              : 'Belum ada transaksi complete',
          style: const TextStyle(fontSize: 16, color: textMain),
        ),
      );
    }

    return ListView.builder(
      itemCount: transaksiList.length,
      itemBuilder: (context, index) {
        final transaksi = transaksiList[index];

        return InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailTransaksiPage(transaksi: transaksi),
              ),
            );

            if (result != null && result == "lunas") {
              setState(() {
                _pendingTransaksi.removeAt(index);
                _completeTransaksi.insert(0, transaksi);
              });
            }
          },
          child: Card(
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kode: ${transaksi['kdTransaksi']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: highlight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Nama: ${transaksi['namaPelanggan'] ?? 'Tanpa Nama'}",
                    style: const TextStyle(fontSize: 14, color: textMain),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Total Hutang: Rp${transaksi['totalHutang']}",
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tanggal: ${transaksi['tanggal']}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color highlight = Color(0xFF00563B);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Transaksi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: highlight,
          elevation: 4,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Text(
                  "Pending",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Complete",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(_pendingTransaksi, 'pending'),
            _buildList(_completeTransaksi, 'complete'),
          ],
        ),
      ),
    );
  }
}

class DetailTransaksiPage extends StatefulWidget {
  final Map<String, dynamic> transaksi;

  const DetailTransaksiPage({Key? key, required this.transaksi})
      : super(key: key);

  @override
  State<DetailTransaksiPage> createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  late double sisaHutang;

  @override
  void initState() {
    super.initState();
    sisaHutang = widget.transaksi['totalHutang'] * 1.0;
  }

  void _showInputCicilan() {
    final TextEditingController cicilanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Input Cicilan"),
          content: TextField(
            controller: cicilanController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Masukkan jumlah cicilan",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                final cicilan = double.tryParse(cicilanController.text) ?? 0;
                if (cicilan > 0) {
                  setState(() {
                    sisaHutang -= cicilan;
                    if (sisaHutang < 0) sisaHutang = 0;
                  });
                  Navigator.pop(ctx);

                  if (sisaHutang == 0) {
                    Navigator.pop(context, "lunas");
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00563B),
                foregroundColor: Colors.white,
              ),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final produk = widget.transaksi['produk'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        backgroundColor: const Color(0xFF00563B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kode Transaksi: ${widget.transaksi['kdTransaksi']}"),
            Text("Nama: ${widget.transaksi['namaPelanggan']}"),
            Text("Tanggal: ${widget.transaksi['tanggal']}"),
            const SizedBox(height: 12),
            Text("Total Hutang: Rp${widget.transaksi['totalHutang']}"),
            
            // 🔹 Tombol input cicilan diletakkan di atas sisa hutang
            if (sisaHutang > 0) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _showInputCicilan,
                icon: const Icon(Icons.payments),
                label: const Text("Input Cicilan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00563B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            Text("Sisa Hutang: Rp$sisaHutang",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const Divider(),
            const Text(
              "Detail Produk:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: produk.length,
                itemBuilder: (context, index) {
                  final item = produk[index];
                  final jumlah = item['jumlah'] ?? 0;
                  final price = item['price'] ?? 0;
                  final total = jumlah * price;

                  return ListTile(
                    title: Text("${item['name']} (${item['size']})"),
                    subtitle: Text("Jumlah: $jumlah"),
                    trailing: Text("Rp$total"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
