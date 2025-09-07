import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/debt_api.dart';
import 'package:flutter_toko_bahan_kue/pages/pending_detail_page.dart';
import '../models/debt_model.dart';

class PendingPage extends StatelessWidget {
  const PendingPage({Key? key}) : super(key: key);

  Widget _buildListItem(Debt transaksi, BuildContext context) {
    const Color highlight = Color(0xFF00563B);
    const Color cardColor = Color(0xFFF1F8F5);
    const Color textMain = Color(0xFF222222);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PendingDetailScreen(debtId: transaksi.id),
          ),
        );
      },
      onHover: (isHovering) {
        // Opsional: Tambahkan logika jika diperlukan saat hover
      },
      splashColor: Colors.blue.withOpacity(0.2), // Efek ripple saat diklik
      hoverColor: Colors.blue.withOpacity(0.1), // Warna saat hover
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kode: ${transaksi.referenceCode}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: highlight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Nama: ${transaksi.related}",
                style: const TextStyle(fontSize: 14, color: textMain),
              ),
              const SizedBox(height: 6),
              Text(
                "Total Hutang: Rp${transaksi.totalAmount}",
                style: const TextStyle(fontSize: 14, color: Colors.redAccent),
              ),
              const SizedBox(height: 6),
              Text(
                "Jatuh Tempo: ${transaksi.dueDate.toLocal()}",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(Future<List<Debt>> future, String status) {
    const Color highlight = Color(0xFF00563B);
    const Color cardColor = Color(0xFFF1F8F5);
    const Color textMain = Color(0xFF222222);
    return FutureBuilder<List<Debt>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              status == 'PENDING'
                  ? 'Belum ada transaksi pending'
                  : 'Belum ada transaksi complete',
              style: const TextStyle(fontSize: 16, color: textMain),
            ),
          );
        }
        final transaksiList = snapshot.data!;
        return ListView.builder(
          itemCount: transaksiList.length,
          itemBuilder: (context, index) {
            final transaksi = transaksiList[index];
            return _buildListItem(transaksi, context);
          },
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
              Tab(child: Text("Pending")),
              Tab(child: Text("Complete")),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(DebtApi.fetchDebts("PENDING"), "PENDING"),
            _buildList(DebtApi.fetchDebts("PAID"), "PAID"),
          ],
        ),
      ),
    );
  }
}
