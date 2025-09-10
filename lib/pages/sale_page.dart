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

  // Sales state
  List<Sale> _sales = [];
  int _salesPage = 1;
  bool _isSalesLoading = false;
  bool _salesHasMore = true;
  String _salesSearchQuery = '';

  // Purchase state
  List<Purchase> _purchases = [];
  int _purchasesPage = 1;
  bool _isPurchaseLoading = false;
  bool _purchaseHasMore = true;
  String _purchasesSearchQuery = '';

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    _salesPage = 1;
    _purchasesPage = 1;
    _sales.clear();
    _purchases.clear();
    _salesHasMore = true;
    _purchaseHasMore = true;
    _loadSales();
    _loadPurchases();
  }

  Future<void> _loadSales() async {
    if (_isSalesLoading || !_salesHasMore) return;
    setState(() => _isSalesLoading = true);

    try {
      final result = await SaleApi.fetchSalesWithPagination(
        _salesSearchQuery,
        page: _salesPage,
        limit: 10,
      );

      setState(() {
        if (result.isEmpty) {
          _salesHasMore = false;
        } else {
          _sales.addAll(result["data"]);
          _salesPage++;
        }
      });
    } finally {
      setState(() => _isSalesLoading = false);
    }
  }

  Future<void> _loadPurchases() async {
    if (_isPurchaseLoading || !_purchaseHasMore) return;
    setState(() => _isPurchaseLoading = true);

    try {
      final result = await SaleApi.fetchPurchasesWithPagination(
        _purchasesSearchQuery,
        page: _purchasesPage,
        limit: 10,
      );

      setState(() {
        if (result.isEmpty) {
          _purchaseHasMore = false;
        } else {
          _purchases.addAll(result["data"]);
          _purchasesPage++;
        }
      });
    } finally {
      setState(() => _isPurchaseLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_tabController.index == 0) {
      _salesSearchQuery = value;
    } else {
      _purchasesSearchQuery = value;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ==========================
  // SALES LIST
  // ==========================
  Widget _buildSalesList() {
    if (_sales.isEmpty && _isSalesLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_sales.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada riwayat penjualan",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!_isSalesLoading &&
            _salesHasMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadSales();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _sales.length + (_salesHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _sales.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final sale = _sales[index];
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
      ),
    );
  }

  // ==========================
  // PURCHASE LIST
  // ==========================
  Widget _buildPurchaseList() {
    if (_purchases.isEmpty && _isPurchaseLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_purchases.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada riwayat pembelian",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!_isPurchaseLoading &&
            _purchaseHasMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadPurchases();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _purchases.length + (_purchaseHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _purchases.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final purchase = _purchases[index];
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
      ),
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
  final bool isSalesTab;
  SearchDelegateImpl(this.isSalesTab)
    : super(searchFieldLabel: "Cari transaksi...");

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
    return const Center(child: Text("Gunakan pencarian di halaman utama"));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text("Ketik untuk mencari..."));
  }
}
