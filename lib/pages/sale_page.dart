import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_toko_bahan_kue/models/sale_model.dart';
import 'package:flutter_toko_bahan_kue/pages/sale_detail_page.dart';
import '../api/sale_api.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Sale>> _salesFuture;
  late Future<List<Purchase>> _purchaseFuture;
  String _salesSearchQuery = '';
  String _purchasesSearchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  void _refreshData() {
    _salesFuture = SaleApi.fetchSales(_salesSearchQuery);
    _purchaseFuture = SaleApi.fetchPurchase(_purchasesSearchQuery);
    setState(() {});
  }

  void _onSearchChanged(String value) {
    if (_tabController.index == 0) {
      _salesSearchQuery = value;
    } else {
      _purchasesSearchQuery = value;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ==========================
  // WIDGET LIST PENJUALAN
  // ==========================
  Widget _buildSalesList() {
    return FutureBuilder<List<Sale>>(
      future: _salesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Gagal memuat data: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada riwayat penjualan",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final sales = snapshot.data!;
        return ListView.builder(
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SaleDetailScreen(saleCode: sale.code),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header kode + tanggal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "Kode: ${sale.code}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            "${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Pelanggan: ${sale.customerName}",
                        style: const TextStyle(fontSize: 15),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Status: ${sale.status}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: sale.status == "Selesai"
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================
  // WIDGET LIST PEMBELIAN
  // ==========================
  Widget _buildPurchaseList() {
    return FutureBuilder<List<Purchase>>(
      future: _purchaseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Gagal memuat data: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada riwayat pembelian",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final purchases = snapshot.data!;
        return ListView.builder(
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final purchase = purchases[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header kode + tanggal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Kode: ${purchase.code}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${purchase.createdAt.day}/${purchase.createdAt.month}/${purchase.createdAt.year}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "Sales: ${purchase.salesName}",
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Distributor: ${purchase.distributorName}",
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Status: ${purchase.status}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: purchase.status == "Selesai"
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================
  // BUILD
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF1F8E9),
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
            onPressed: () async {
              final result = await showSearch<String>(
                context: context,
                delegate: SearchDelegateImpl(_tabController.index == 0),
              );
              if (result != null && result.isNotEmpty) {
                _onSearchChanged(result);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                border: Border(
                  bottom: BorderSide(color: Colors.green[200]!, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF2E7D32),
                unselectedLabelColor: Colors.black54,
                indicatorColor: const Color(0xFF2E7D32),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(
                    text: "Penjualan",
                    icon: Icon(Icons.sell_outlined, size: 20),
                  ),
                  Tab(
                    text: "Pembelian",
                    icon: Icon(Icons.shopping_bag_outlined, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildSalesList(), _buildPurchaseList()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// Custom Search Delegate
// ===============================
class SearchDelegateImpl extends SearchDelegate<String> {
  final bool isSalesTab; // true = Penjualan, false = Pembelian
  SearchDelegateImpl(this.isSalesTab)
    : super(searchFieldLabel: "Cari transaksi...");

  Future<List<dynamic>> _fetchResults(String query) async {
    if (query.isEmpty) return [];
    return isSalesTab
        ? await SaleApi.fetchSales(query)
        : await SaleApi.fetchPurchase(query);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Tidak ada hasil"));
        }

        final results = snapshot.data!;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            if (isSalesTab) {
              final sale = results[index] as Sale;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text("Kode: ${sale.code}"),
                  subtitle: Text("Pelanggan: ${sale.customerName}"),
                  trailing: Text(
                    sale.status,
                    style: TextStyle(
                      color: sale.status == "Selesai"
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SaleDetailScreen(saleCode: sale.code),
                      ),
                    );
                  },
                ),
              );
            } else {
              final purchase = results[index] as Purchase;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text("Kode: ${purchase.code}"),
                  subtitle: Text("Distributor: ${purchase.distributorName}"),
                  trailing: Text(
                    purchase.status,
                    style: TextStyle(
                      color: purchase.status == "Selesai"
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Ketik untuk mencari..."));
    }
    return buildResults(context);
  }
}
