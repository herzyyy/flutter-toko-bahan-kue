import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_toko_bahan_kue/models/sale_model.dart';
import 'package:flutter_toko_bahan_kue/pages/sale_detail_page.dart';
import 'package:intl/intl.dart';
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
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Update search controller text when tab changes
      _searchController.text = _tabController.index == 0
          ? _salesSearchQuery
          : _purchasesSearchQuery;
      setState(() {}); // perbarui UI agar hintText search berubah
    });
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
        search: _salesSearchQuery.isNotEmpty ? _salesSearchQuery : null,
        page: _salesPage,
        limit: 10,
      );

      final List<dynamic> data = (result is Map && result['data'] is List)
          ? result['data'] as List<dynamic>
          : (result is List ? result as List<dynamic> : <dynamic>[]);

      setState(() {
        if (data.isEmpty) {
          _salesHasMore = false;
        } else {
          final newSales = data.map((e) => e as Sale).toList();
          _sales.addAll(newSales);

          // Urutkan seluruh list berdasarkan relevansi jika ada query pencarian
          if (_salesSearchQuery.isNotEmpty) {
            _sales = _sortSalesByRelevance(_sales, _salesSearchQuery);
          }

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
        search: _purchasesSearchQuery.isNotEmpty ? _purchasesSearchQuery : null,
        page: _purchasesPage,
        limit: 10,
      );

      final List<dynamic> data = (result is Map && result['data'] is List)
          ? result['data'] as List<dynamic>
          : (result is List ? result as List<dynamic> : <dynamic>[]);

      setState(() {
        if (data.isEmpty) {
          _purchaseHasMore = false;
        } else {
          final newPurchases = data.map((e) => e as Purchase).toList();
          _purchases.addAll(newPurchases);

          // Urutkan seluruh list berdasarkan relevansi jika ada query pencarian
          if (_purchasesSearchQuery.isNotEmpty) {
            _purchases = _sortPurchasesByRelevance(
              _purchases,
              _purchasesSearchQuery,
            );
          }

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
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ==========================
  // SORTING BY RELEVANCE
  // ==========================

  /// Menghitung skor relevansi untuk Sale berdasarkan query pencarian
  int _calculateSaleRelevance(Sale sale, String query) {
    if (query.isEmpty) return 0;

    final lowerQuery = query.toLowerCase();
    final lowerCode = sale.code.toLowerCase();
    final lowerCustomerName = sale.customerName.toLowerCase();

    // Skor 3: Kode dimulai dengan query (paling relevan)
    if (lowerCode.startsWith(lowerQuery)) {
      return 3;
    }

    // Skor 2: Nama pelanggan dimulai dengan query
    if (lowerCustomerName.startsWith(lowerQuery)) {
      return 2;
    }

    // Skor 1: Kode atau nama pelanggan mengandung query
    if (lowerCode.contains(lowerQuery) ||
        lowerCustomerName.contains(lowerQuery)) {
      return 1;
    }

    return 0;
  }

  /// Menghitung skor relevansi untuk Purchase berdasarkan query pencarian
  int _calculatePurchaseRelevance(Purchase purchase, String query) {
    if (query.isEmpty) return 0;

    final lowerQuery = query.toLowerCase();
    final lowerCode = purchase.code.toLowerCase();
    final lowerSalesName = purchase.salesName.toLowerCase();
    final lowerDistributorName = purchase.distributorName.toLowerCase();

    // Skor 3: Kode dimulai dengan query (paling relevan)
    if (lowerCode.startsWith(lowerQuery)) {
      return 3;
    }

    // Skor 2: Nama sales atau distributor dimulai dengan query
    if (lowerSalesName.startsWith(lowerQuery) ||
        lowerDistributorName.startsWith(lowerQuery)) {
      return 2;
    }

    // Skor 1: Kode, nama sales, atau distributor mengandung query
    if (lowerCode.contains(lowerQuery) ||
        lowerSalesName.contains(lowerQuery) ||
        lowerDistributorName.contains(lowerQuery)) {
      return 1;
    }

    return 0;
  }

  /// Mengurutkan list Sale berdasarkan relevansi dengan query
  List<Sale> _sortSalesByRelevance(List<Sale> sales, String query) {
    if (query.isEmpty) return sales;

    final sorted = List<Sale>.from(sales);
    sorted.sort((a, b) {
      final scoreA = _calculateSaleRelevance(a, query);
      final scoreB = _calculateSaleRelevance(b, query);

      // Urutkan berdasarkan skor relevansi (tertinggi di atas)
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }

      // Jika skor sama, urutkan berdasarkan tanggal terbaru
      return b.createdAt.compareTo(a.createdAt);
    });

    return sorted;
  }

  /// Mengurutkan list Purchase berdasarkan relevansi dengan query
  List<Purchase> _sortPurchasesByRelevance(
    List<Purchase> purchases,
    String query,
  ) {
    if (query.isEmpty) return purchases;

    final sorted = List<Purchase>.from(purchases);
    sorted.sort((a, b) {
      final scoreA = _calculatePurchaseRelevance(a, query);
      final scoreB = _calculatePurchaseRelevance(b, query);

      // Urutkan berdasarkan skor relevansi (tertinggi di atas)
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }

      // Jika skor sama, urutkan berdasarkan tanggal terbaru
      return b.createdAt.compareTo(a.createdAt);
    });

    return sorted;
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
        itemCount: _sales.length,
        itemBuilder: (context, index) {
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
                          DateFormat('dd/MM/yyyy').format(sale.createdAt),
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
        itemCount: _purchases.length,
        itemBuilder: (context, index) {
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
                        DateFormat('dd/MM/yyyy').format(purchase.createdAt),
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ===========================
            // TABBAR
            // ===========================
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

            // ===========================
            // SEARCH BAR PER TAB
            // ===========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _onSearchChanged(value),
                      decoration: InputDecoration(
                        hintText: _tabController.index == 0
                            ? "Cari penjualan..."
                            : "Cari pembelian...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.green,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if ((_tabController.index == 0 &&
                          _salesSearchQuery.isNotEmpty) ||
                      (_tabController.index == 1 &&
                          _purchasesSearchQuery.isNotEmpty))
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          if (_tabController.index == 0) {
                            _salesSearchQuery = '';
                          } else {
                            _purchasesSearchQuery = '';
                          }
                          _searchController.clear();
                          _loadInitialData();
                        });
                      },
                    ),
                ],
              ),
            ),

            // ===========================
            // TAB CONTENT
            // ===========================
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
