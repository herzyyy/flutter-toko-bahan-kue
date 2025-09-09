import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/debt_api.dart';
import 'package:flutter_toko_bahan_kue/models/debt_model.dart';
import 'package:flutter_toko_bahan_kue/pages/pending_detail_page.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class PendingPage extends StatefulWidget {
  const PendingPage({Key? key}) : super(key: key);

  @override
  State<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Debt>> _pendingDebtsFuture;
  late Future<List<Debt>> _paidDebtsFuture;
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  void _refreshData() {
    _pendingDebtsFuture = DebtApi.fetchDebtsWithPagination(
      status: 'PENDING',
      search: _searchQuery,
      page: 1,
      limit: 10,
    ).then((result) => result['data']);

    _paidDebtsFuture = DebtApi.fetchDebtsWithPagination(
      status: 'PAID',
      search: _searchQuery,
      page: 1,
      limit: 10,
    ).then((result) => result['data']);

    setState(() {});
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
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

  // Widget untuk daftar utang
  Widget _buildDebtList(Future<List<Debt>> future) {
    return FutureBuilder<List<Debt>>(
      future: future,
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
              "Tidak ada data utang",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        final debts = snapshot.data!;
        return ListView.builder(
          itemCount: debts.length,
          itemBuilder: (context, index) {
            final debt = debts[index];
            return _buildDebtCard(debt);
          },
        );
      },
    );
  }

  // Widget untuk kartu utang
  Widget _buildDebtCard(Debt debt) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PendingDetailPage(debtId: debt.id)),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      "Kode: ${debt.referenceCode}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(debt.dueDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Nama pelanggan
              Text(
                "Pelanggan: ${debt.related}",
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 4),

              // Status
              Text(
                "Status: ${debt.status}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: debt.status == "PAID" ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 4),

              // Jumlah utang
              Text(
                "Jumlah: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(debt.totalAmount)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF1F8E9),
        title: const Text(
          "Daftar Utang",
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
                delegate: SearchDelegateImpl(),
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
                    text: "Menunggu",
                    icon: Icon(Icons.pending_actions_outlined, size: 20),
                  ),
                  Tab(
                    text: "Selesai",
                    icon: Icon(Icons.check_circle_outline, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDebtList(_pendingDebtsFuture),
                  _buildDebtList(_paidDebtsFuture),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Search Delegate
class SearchDelegateImpl extends SearchDelegate<String> {
  SearchDelegateImpl()
    : super(searchFieldLabel: "Cari nama pelanggan atau kode...");

  Future<List<Debt>> _fetchResults(String query) async {
    if (query.isEmpty) return [];
    return DebtApi.fetchDebtsWithPagination(
      status: "SALE",
      search: query,
      page: 1,
      limit: 10,
    ).then((result) => result['data']);
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
    return FutureBuilder<List<Debt>>(
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
            final debt = results[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ListTile(
                title: Text("Kode: ${debt.referenceCode}"),
                subtitle: Text("Pelanggan: ${debt.related}"),
                trailing: Text(
                  debt.status,
                  style: TextStyle(
                    color: debt.status == "PAID" ? Colors.green : Colors.orange,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PendingDetailPage(debtId: debt.id),
                    ),
                  );
                },
              ),
            );
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
