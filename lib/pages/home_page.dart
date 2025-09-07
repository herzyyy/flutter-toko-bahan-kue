import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/auth_api.dart';
import 'package:flutter_toko_bahan_kue/api/product_api.dart';
import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';
import 'package:flutter_toko_bahan_kue/models/product_model.dart';
import 'package:flutter_toko_bahan_kue/models/user_model.dart';
import 'stok_page.dart';
import 'sale_page.dart';
import 'pending_page.dart';
import '../data/cart_data.dart'; // ✅ Import cart global

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  Future<List<Product>> products = ProductApi.fetchProductList();

  // final List<String> sizeOptions = ['250g', '500g', '1kg'];
  List<Product> originalProducts = [];
  List<Product> displayedProducts = [];

  // Map untuk menyimpan ukuran yang dipilih tiap produk berdasarkan nama produk
  Map<String, String?> selectedSizes = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
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

  void _addToCart(Product product) {
    final sizeId = selectedSizes[product.sku];
    if (sizeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ukuran terlebih dahulu')),
      );
      return;
    }

    final size = product.sizes.firstWhere((s) => s.id.toString() == sizeId);

    setState(() {
      final existingIndex = globalCart.indexWhere(
        (item) => item['sku'] == product.sku && item['size_id'] == size.id,
      );

      if (existingIndex != -1) {
        globalQuantities[existingIndex]++;
      } else {
        globalCart.add({
          'sku': product.sku,
          'name': product.name,
          'size_id': size.id,
          'size_name': size.name,
          'stock': size.stock,
          'price': size.sellPrice,
          'sizes': product.sizes, // ✅ simpan list ukuran
        });
        globalQuantities.add(1);
      }

      selectedSizes[product.sku] = null;
    });
  }

  void _filterProducts(String query) async {
    final allProducts = await products;
    setState(() {
      if (query.isEmpty) {
        displayedProducts = allProducts;
      } else {
        displayedProducts = allProducts
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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

        if (displayedProducts.isEmpty) {
          originalProducts = snapshot.data!;
          displayedProducts = List<Product>.from(originalProducts);
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _filterProducts,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isWideScreen
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: displayedProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(
                            displayedProducts[index],
                            index,
                          );
                        },
                      )
                    : ListView.separated(
                        itemCount: displayedProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildProductCard(
                            displayedProducts[index],
                            index,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, int index) {
    final selectedSizeId = selectedSizes[product.sku];
    final selectedSize = selectedSizeId == null
        ? null
        : product.sizes.firstWhere(
            (s) => s.id.toString() == selectedSizeId,
            orElse: () => product.sizes.first,
          );

    return Card(
      elevation: 6,
      color: const Color(0xFFF1F8F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Nama produk
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00563B),
              ),
            ),

            const SizedBox(height: 12),

            // --- Dropdown ukuran + stok + harga
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedSizeId,
                  hint: const Text('Pilih ukuran'),
                  items: product.sizes
                      .map(
                        (size) => DropdownMenuItem<String>(
                          value: size.id.toString(),
                          child: Text(size.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSizes[product.sku] = val;
                    });
                  },
                ),
                const SizedBox(width: 12),

                // Stok
                if (selectedSize != null)
                  Text(
                    'Stok: ${selectedSize.stock}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF00563B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                const Spacer(),

                // Harga
                Text(
                  selectedSize != null
                      ? 'Rp ${selectedSize.sellPrice}'
                      : 'Rp -',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00563B),
                  ),
                ),

                const SizedBox(width: 12),

                // Tombol tambah
                ElevatedButton(
                  onPressed: () => _addToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00563B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
      onPressed: () async {
        final updated = await Navigator.pushNamed(context, '/cart');
        if (updated == true) {
          setState(() {
            selectedSizes.clear();
          });
        }
      },
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Color(0xFF667eea)),
              SizedBox(width: 10),
              Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await AuthApi.logout();
      } catch (e) {
        debugPrint('Logout gagal ke server: $e');
      }

      await AuthService.clearToken();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<User> user = AuthApi.current();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Terjadi kesalahan: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Tidak ada data user')),
          );
        }

        final currentUser = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF00563B),
            elevation: 3,
            titleSpacing: 16,
            title: const Row(
              children: [
                Icon(Icons.store, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Toko Azka',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              _buildCartIcon(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.pushNamed(context, '/profile');
                  } else if (value == 'logout') {
                    _logout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                  const PopupMenuItem(value: 'profile', child: Text('Profil')),
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
              const SalePage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavTapped,
            selectedItemColor: const Color(0xFF00563B),
            unselectedItemColor: Colors.grey[500],
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
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
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Riwayat',
              ),
            ],
          ),
        );
      },
    );
  }
}
