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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  String _searchQuery = '';
  Timer? _debounceTimer;

  // Pagination state untuk pending & paid
  List<Debt> _pendingDebts = [];
  List<Debt> _paidDebts = [];
  int _pendingPage = 1;
  int _paidPage = 1;
  bool _isPendingLoading = false;
  bool _isPaidLoading = false;
  bool _hasMorePending = true;
  bool _hasMorePaid = true;

  // Scroll controllers untuk mendeteksi scroll ke bawah
  late ScrollController _pendingScrollController;
  late ScrollController _paidScrollController;

  @override
  bool get wantKeepAlive => true; // biar tidak refresh

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _pendingScrollController = ScrollController();
    _paidScrollController = ScrollController();

    _pendingScrollController.addListener(_pendingScrollListener);
    _paidScrollController.addListener(_paidScrollListener);

    _loadPendingDebts(reset: true);
    _loadPaidDebts(reset: true);
  }

  void _pendingScrollListener() {
    if (_pendingScrollController.position.atEdge) {
      final isBottom =
          _pendingScrollController.position.pixels ==
          _pendingScrollController.position.maxScrollExtent;
      if (isBottom && !_isPendingLoading && _hasMorePending) {
        _loadPendingDebts();
      }
    } else {
      // alternatif: trigger ketika dekat bottom (200 px tersisa)
      if (_pendingScrollController.position.pixels >=
              _pendingScrollController.position.maxScrollExtent - 200 &&
          !_isPendingLoading &&
          _hasMorePending) {
        _loadPendingDebts();
      }
    }
    // Untuk debugging, bisa aktifkan print ini:
    // print("pending: ${_pendingScrollController.position.pixels} / ${_pendingScrollController.position.maxScrollExtent}");
  }

  void _paidScrollListener() {
    if (_paidScrollController.position.atEdge) {
      final isBottom =
          _paidScrollController.position.pixels ==
          _paidScrollController.position.maxScrollExtent;
      if (isBottom && !_isPaidLoading && _hasMorePaid) {
        _loadPaidDebts();
      }
    } else {
      if (_paidScrollController.position.pixels >=
              _paidScrollController.position.maxScrollExtent - 200 &&
          !_isPaidLoading &&
          _hasMorePaid) {
        _loadPaidDebts();
      }
    }
    // Untuk debugging, bisa aktifkan print ini:
    // print("paid: ${_paidScrollController.position.pixels} / ${_paidScrollController.position.maxScrollExtent}");
  }

  Future<void> _loadPendingDebts({bool reset = false}) async {
    if (_isPendingLoading) return;

    setState(() => _isPendingLoading = true);

    try {
      if (reset) {
        _pendingPage = 1;
        _pendingDebts.clear();
        _hasMorePending = true;
        // scroll ke atas kalau perlu
        if (_pendingScrollController.hasClients) {
          _pendingScrollController.jumpTo(0);
        }
      }

      final result = await DebtApi.fetchDebtsWithPagination(
        status: 'PENDING',
        search: _searchQuery,
        page: _pendingPage,
        limit: 10,
      );

      final newData = result['data'] as List<dynamic>; // ambil list dari API
      setState(() {
        // Pastikan tipe cocok; jika result['data'] sudah List<Debt> ini tetap works
        _pendingDebts.addAll(newData.cast<Debt>());
        _hasMorePending = newData.length == 10;
        if (_hasMorePending) _pendingPage++;
        _isPendingLoading = false;
      });
    } catch (e) {
      setState(() => _isPendingLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  Future<void> _loadPaidDebts({bool reset = false}) async {
    if (_isPaidLoading) return;

    setState(() => _isPaidLoading = true);

    try {
      if (reset) {
        _paidPage = 1;
        _paidDebts.clear();
        _hasMorePaid = true;
        if (_paidScrollController.hasClients) {
          _paidScrollController.jumpTo(0);
        }
      }

      final result = await DebtApi.fetchDebtsWithPagination(
        status: 'PAID',
        search: _searchQuery,
        page: _paidPage,
        limit: 10,
      );

      final newData = result['data'] as List<dynamic>;
      setState(() {
        _paidDebts.addAll(newData.cast<Debt>());
        _hasMorePaid = newData.length == 10;
        if (_hasMorePaid) _paidPage++;
        _isPaidLoading = false;
      });
    } catch (e) {
      setState(() => _isPaidLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _loadPendingDebts(reset: true);
      _loadPaidDebts(reset: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounceTimer?.cancel();
    _pendingScrollController.removeListener(_pendingScrollListener);
    _paidScrollController.removeListener(_paidScrollListener);
    _pendingScrollController.dispose();
    _paidScrollController.dispose();
    super.dispose();
  }

  // Widget untuk daftar utang dengan pagination
  Widget _buildDebtList({
    required List<Debt> debts,
    required bool isLoading,
    required bool hasMore,
    required ScrollController controller,
  }) {
    if (debts.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (debts.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada data utang",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: controller, // penting: pasang controller
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: debts.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == debts.length) {
          // Pastikan tidak ada loading spinner jika tidak ada data lagi
          if (!hasMore) return const SizedBox.shrink();

          // Tampilkan loading spinner hanya jika masih ada data
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final debt = debts[index];
        return _buildDebtCard(debt);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // disamakan dengan SalePage
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // disamakan dengan SalePage
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
                        fontSize: 16, // sama dengan SalePage
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(debt.dueDate),
                    style: const TextStyle(
                      fontSize: 14, // sama dengan SalePage
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Nama pelanggan
              Text(
                "Pelanggan: ${debt.related}",
                style: const TextStyle(fontSize: 15), // sama dengan SalePage
              ),
              // const SizedBox(height: 4),
              // // Status
              // Text(
              //   "Status: ${debt.status}",
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w500,
              //     color: debt.status == "PAID" ? Colors.green : Colors.orange,
              //   ),
              // ),
              const SizedBox(height: 4),
              // Jumlah utang (tambahan, tetap ada di Pending)
              Text(
                "Jumlah: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(debt.totalAmount)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15, // disamakan supaya serasi
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
    super.build(context); // wajib kalau pakai keepAlive

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
                delegate: SearchDelegateImpl(
                  _tabController.index == 0 ? "PENDING" : "PAID",
                ),
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
                  _buildDebtList(
                    debts: _pendingDebts,
                    isLoading: _isPendingLoading,
                    hasMore: _hasMorePending,
                    controller: _pendingScrollController,
                  ),
                  _buildDebtList(
                    debts: _paidDebts,
                    isLoading: _isPaidLoading,
                    hasMore: _hasMorePaid,
                    controller: _paidScrollController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Search Delegate dengan status
class SearchDelegateImpl extends SearchDelegate<String> {
  final String status;
  SearchDelegateImpl(this.status)
    : super(searchFieldLabel: "Cari nama pelanggan atau kode...");

  Future<List<Debt>> _fetchResults(String query) async {
    if (query.isEmpty) return [];
    return DebtApi.fetchDebtsWithPagination(
      status: status,
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
