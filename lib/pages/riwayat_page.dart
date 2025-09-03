import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/models/history_model.dart';
import '../api/history_api.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late Future<List<SaleHistory>> _salesHistory;
  late Future<List<PurchaseHistory>> _purchaseHistory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Panggil API
    _salesHistory = HistoryApi.fetchSalesHistory();
    _purchaseHistory = HistoryApi.fetchPurchaseHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🔹 Widget List Riwayat Penjualan
  Widget _buildSalesHistory() {
    return FutureBuilder<List<SaleHistory>>(
      future: _salesHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Gagal memuat data: ${snapshot.error.toString()}"),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Belum ada riwayat penjualan"));
        }

        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final sale = data[index];
            return Card(
              child: ListTile(
                title: Text("Kode: ${sale.code}"),
                subtitle: Text(
                  "Customer: ${sale.customerName}\nStatus: ${sale.status}",
                ),
                trailing: Text(
                  "${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🔹 Widget List Riwayat Pembelian
  Widget _buildPurchaseHistory() {
    return FutureBuilder<List<PurchaseHistory>>(
      future: _purchaseHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Gagal memuat data: ${snapshot.error.toString()}"),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Belum ada riwayat pembelian"));
        }

        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final purchase = data[index];
            return Card(
              child: ListTile(
                title: Text("Kode: ${purchase.code}"),
                subtitle: Text(
                  "Sales: ${purchase.salesName}\nDistributor: ${purchase.distributorName}\nStatus: ${purchase.status}",
                ),
                trailing: Text(
                  "${purchase.createdAt.day}/${purchase.createdAt.month}/${purchase.createdAt.year}",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Penjualan"),
            Tab(text: "Pembelian"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSalesHistory(), _buildPurchaseHistory()],
      ),
    );
  }
}
