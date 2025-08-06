import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/product_api.dart';
import 'package:flutter_toko_bahan_kue/models/product_model.dart';
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

  Future<List<Product>> products = ProductApi.fetchProductList();

  List<Map<String, dynamic>> cart = [];

  final List<String> sizeOptions = ['250g', '500g', '1kg'];

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

    return FutureBuilder<List<Product>>(
      future: products,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada produk tersedia.'));
        }

        final productList = snapshot.data!;

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
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    final product = {
                      'sku': productList[index].sku,
                      'name': productList[index].name,
                      'category': productList[index].category.name,
                      'size': sizeOptions.first, // tambahkan default size
                    };
                    return _buildProductCard(product);
                  },
                )
              : ListView.separated(
                  itemCount: productList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = {
                      'sku': productList[index].sku,
                      'name': productList[index].name,
                      'category': productList[index].category.name,
                      'size': sizeOptions.first, // tambahkan default size
                    };
                    return _buildProductCard(product);
                  },
                ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      color: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas: Nama produk & stok di pojok kanan atas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00563B),
                    ),
                    overflow: TextOverflow.ellipsis,
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
                    'Stok: 1',
                    style: const TextStyle(
                      color: Color(0xFF00563B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Baris bawah: Ukuran, harga, tombol cart sejajar
            Row(
              children: [
                const Text(
                  'Ukuran : ',
                  style: TextStyle(fontSize: 14, color: Color(0xFF00563B)),
                ),
                DropdownButton<String>(
                  value: product['size'] ?? sizeOptions.first,
                  items: sizeOptions
                      .map(
                        (size) => DropdownMenuItem(
                          value: size,
                          child: Text(
                            size,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      product['size'] = val!;
                    });
                  },
                  underline: const SizedBox(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF00563B),
                  ),
                  dropdownColor: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  'Rp. 7000',
                  style: const TextStyle(
                    color: Color(0xFF00563B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _addToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00563B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                  ),
                  child: const Icon(Icons.add_shopping_cart),
                ),
              ],
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
      backgroundColor: Colors.white,
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
