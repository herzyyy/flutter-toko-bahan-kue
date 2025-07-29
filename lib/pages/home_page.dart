import 'package:flutter/material.dart';
import 'stok_page.dart';
import 'riwayat_page.dart';
import 'pending_page.dart'; // Tambahkan import

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  List<Map<String, dynamic>> products = [
    {'name': 'Tepung Terigu', 'size': '1kg', 'stock': 20, 'price': 12000},
    {'name': 'Gula Pasir', 'size': '1kg', 'stock': 15, 'price': 14000},
    {'name': 'Mentega', 'size': '200gr', 'stock': 10, 'price': 8000},
    {'name': 'Coklat Bubuk', 'size': '100gr', 'stock': 8, 'price': 10000},
  ];
  List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add(product);
    });
  }

  Widget _buildProductList(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: isWideScreen
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
              },
            )
          : ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
              },
            ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      color: const Color(0xFFE8F5E9), // Ubah warna card jadi hijau muda
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00563B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00563B).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Stok: ${product['stock']}',
                          style: const TextStyle(
                            color: Color(0xFF00563B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ukuran: ${product['size']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp${product['price']}',
                    style: const TextStyle(
                      color: Color(0xFF00563B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _addToCart(product),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00563B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartIcon() {
    return IconButton(
      icon: const Icon(Icons.shopping_cart, color: Colors.white),
      onPressed: () {
        Navigator.pushNamed(context, '/cart', arguments: cart);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00563B),
        elevation: 2,
        title: Row(
          children: [
            const Icon(Icons.store, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Toko Azka',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          _buildCartIcon(),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Dayat Saputra',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                  ],
                ),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.white, // Ubah background halaman jadi putih
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildProductList(context),
          const StokPage(),
          const PendingPage(),
          const RiwayatPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: const Color(0xFF00563B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Utama'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Stok Masuk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pending',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}
