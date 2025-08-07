import 'package:flutter/material.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({Key? key}) : super(key: key);

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  static final List<Map<String, dynamic>> _riwayatTransaksi = [];
  static final List<Map<String, dynamic>> _riwayatBarangMasuk = [];

  List<Map<String, dynamic>> _filteredTransaksi = [];
  List<Map<String, dynamic>> _filteredBarangMasuk = [];

  int _selectedTab = 0;
  String _searchKeyword = '';
  DateTimeRange? _selectedDateRange;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final transaksi =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (transaksi != null && transaksi.containsKey('jenis')) {
      if (transaksi['jenis'] == 'masuk') {
        _riwayatBarangMasuk.insert(0, transaksi);
      } else {
        _riwayatTransaksi.insert(0, transaksi);
      }
    }

    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      final keyword = _searchKeyword.toLowerCase();

      _filteredTransaksi = _riwayatTransaksi.where((item) {
        final tanggal =
            DateTime.tryParse(item['tanggal'] ?? '') ?? DateTime(2000);
        final nama = item['namaPelanggan']?.toLowerCase() ?? '';
        final matchKeyword = keyword.isEmpty || nama.contains(keyword);
        final matchDate =
            _selectedDateRange == null ||
            (_selectedDateRange!.start.isBefore(tanggal) &&
                _selectedDateRange!.end.isAfter(tanggal));
        return matchKeyword && matchDate;
      }).toList();

      _filteredBarangMasuk = _riwayatBarangMasuk.where((item) {
        final tanggal =
            DateTime.tryParse(item['tanggal'] ?? '') ?? DateTime(2000);
        final distributor = item['distributor']?.toLowerCase() ?? '';
        final matchKeyword = keyword.isEmpty || distributor.contains(keyword);
        final matchDate =
            _selectedDateRange == null ||
            (_selectedDateRange!.start.isBefore(tanggal) &&
                _selectedDateRange!.end.isAfter(tanggal));
        return matchKeyword && matchDate;
      }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchKeyword = '';
      _selectedDateRange = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    const highlight = Color(0xFF00563B);
    const cardColor = Color(0xFFF1F8F5);
    const textMain = Color(0xFF222222);
    const textSub = Color(0xFF4F4F4F);

    final isTransaksiTab = _selectedTab == 0;
    final listData = isTransaksiTab ? _filteredTransaksi : _filteredBarangMasuk;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: highlight,
        title: const Text('Riwayat', style: TextStyle(color: Colors.white)),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: highlight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton(
                  icon: Icons.receipt_long,
                  label: 'Transaksi',
                  selected: _selectedTab == 0,
                  onTap: () {
                    setState(() => _selectedTab = 0);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 32),
                _buildTabButton(
                  icon: Icons.inventory_2,
                  label: 'Barang Masuk',
                  selected: _selectedTab == 1,
                  onTap: () {
                    setState(() => _selectedTab = 1);
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (value) {
                      _searchKeyword = value;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  tooltip: 'Filter Tanggal',
                  onPressed: _selectDateRange,
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Reset Filter',
                  onPressed: _clearFilters,
                ),
              ],
            ),
          ),
          Expanded(
            child: listData.isEmpty
                ? Center(
                    child: Text(
                      isTransaksiTab
                          ? 'Belum ada transaksi'
                          : 'Belum ada barang masuk',
                      style: const TextStyle(fontSize: 16, color: textMain),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listData.length,
                    itemBuilder: (context, index) {
                      final data = listData[index];
                      return isTransaksiTab
                          ? _buildTransaksiCard(
                              data,
                              highlight,
                              cardColor,
                              textSub,
                            )
                          : _buildBarangMasukCard(
                              data,
                              highlight,
                              cardColor,
                              textSub,
                            );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransaksiCard(
    Map<String, dynamic> transaksi,
    Color highlight,
    Color cardColor,
    Color textSub,
  ) {
    final List produk = transaksi['produk'] ?? [];

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 20,
                      color: Color(0xFF00563B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      transaksi['namaPelanggan'] ?? 'Tanpa Nama',
                      style: TextStyle(
                        color: highlight,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaksi['tanggal']?.toString().substring(0, 16) ?? '-',
                      style: TextStyle(color: textSub),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...produk.map((item) {
              final name = item['name'] ?? '';
              final size = item['size'] ?? '';
              final jumlah = item['jumlah'] ?? 0;
              final price = item['price'] ?? 0;
              final total = price * jumlah;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$name ($size) x$jumlah',
                      style: TextStyle(color: textSub),
                    ),
                    Text(
                      'Rp$total',
                      style: TextStyle(
                        color: highlight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
            const Divider(),
            _buildInfoRow('Total', transaksi['total'], highlight, isBold: true),
            _buildInfoRow(
              'Pengurangan',
              transaksi['diskon'],
              highlight,
              isMinus: true,
            ),
            _buildInfoRow(
              'Total Akhir',
              transaksi['totalAkhir'],
              highlight,
              isBold: true,
            ),
            const Divider(),
            _buildInfoRow(
              'Jenis Pembayaran',
              transaksi['jenisPembayaran'],
              textSub,
            ),
            _buildInfoRow(
              'Uang Customer',
              transaksi['uangCustomer'],
              highlight,
            ),
            _buildInfoRow('Kembalian', transaksi['kembalian'], highlight),
          ],
        ),
      ),
    );
  }

  Widget _buildBarangMasukCard(
    Map<String, dynamic> riwayat,
    Color highlight,
    Color cardColor,
    Color textSub,
  ) {
    final produkList = riwayat['produk'] as List<dynamic>? ?? [];
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Distributor: ${riwayat['distributor'] ?? '-'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: highlight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  riwayat['tanggal'] ?? '-',
                  style: TextStyle(color: textSub),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...produkList.map((item) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item['nama']} (${item['ukuran']}) x${item['stok']}',
                    style: TextStyle(color: textSub),
                  ),
                  Text(
                    'Rp${item['harga']}',
                    style: TextStyle(
                      color: highlight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    dynamic value,
    Color color, {
    bool isBold = false,
    bool isMinus = false,
  }) {
    String text = (value is num)
        ? '${isMinus ? '-' : ''}Rp${value.toStringAsFixed(0)}'
        : value?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          if (selected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 24,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
