import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_toko_bahan_kue/api/auth_api.dart';
import 'package:flutter_toko_bahan_kue/api/product_api.dart';
import 'package:flutter_toko_bahan_kue/helper/auth_service.dart';
import 'package:flutter_toko_bahan_kue/models/product_model.dart';
import 'package:flutter_toko_bahan_kue/models/user_model.dart';
import 'stok_page.dart';
import 'sale_page.dart';
import 'pending_page.dart';
import '../data/cart_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late ScrollController _scrollController;

  List<Product> displayedProducts = [];
  Map<String, String?> selectedSizes = {};
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Pagination state
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _loadProducts(); // load awal
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
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

  // Pagination loader
  Future<void> _loadProducts({String query = ""}) async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    try {
      final newProducts = await ProductApi.fetchProductList(
        query,
        page: currentPage,
        limit: 10,
      );

      setState(() {
        displayedProducts.addAll(newProducts);
        currentPage++;
        hasMore = newProducts.isNotEmpty;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat produk: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading) {
      _loadProducts(query: _searchController.text);
    }
  }

  void _addToCart(Product product) {
    final branchInventoryId = selectedSizes[product.sku];
    if (branchInventoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ukuran terlebih dahulu')),
      );
      return;
    }

    final size = product.sizes.firstWhere(
      (s) => s.branchInventoryId.toString() == branchInventoryId,
      orElse: () => product.sizes.first,
    );

    setState(() {
      final existingIndex = globalCart.indexWhere(
        (item) =>
            item['sku'] == product.sku &&
            item['branch_inventory_id'] == size.branchInventoryId,
      );

      if (existingIndex != -1) {
        globalQuantities[existingIndex]++;
      } else {
        globalCart.add({
          'sku': product.sku,
          'name': product.name,
          'branch_inventory_id': size.branchInventoryId,
          'size_name': size.name,
          'stock': size.stock,
          'price': size.sellPrice,
          'sizes': product.sizes,
        });
        globalQuantities.add(1);
      }
      selectedSizes[product.sku] = null;
    });
  }

  void _filterProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        displayedProducts.clear();
        currentPage = 1;
        hasMore = true;
      });
      _loadProducts(query: query);
    });
  }

  Widget _buildProductList(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchBox(),
          const SizedBox(height: 16),
          Expanded(
            child: displayedProducts.isEmpty && !isLoading
                ? const Center(
                    child: Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : isWideScreen
                ? GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: displayedProducts.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < displayedProducts.length) {
                        return _buildProductCard(
                          displayedProducts[index],
                          index,
                        );
                      } else {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  )
                : ListView.separated(
                    controller: _scrollController,
                    itemCount: displayedProducts.length + (isLoading ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index < displayedProducts.length) {
                        return _buildProductCard(
                          displayedProducts[index],
                          index,
                        );
                      } else {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterProducts,
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00563B)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF00563B)),
                  onPressed: () {
                    _searchController.clear();
                    _filterProducts('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    final selectedBranchInventoryId = selectedSizes[product.sku];
    final selectedSize = selectedBranchInventoryId == null
        ? null
        : product.sizes.firstWhere(
            (s) => s.branchInventoryId.toString() == selectedBranchInventoryId,
            orElse: () => product.sizes.first,
          );

    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00563B),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButton<String>(
                    value: selectedBranchInventoryId,
                    hint: const Text('Pilih ukuran'),
                    items: product.sizes.map((size) {
                      return DropdownMenuItem<String>(
                        value: size.branchInventoryId.toString(),
                        child: Text(size.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedSizes[product.sku] = val;
                      });
                    },
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: 12),
                if (selectedSize != null)
                  Text(
                    'Stok: ${selectedSize.stock}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF00563B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const Spacer(),
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
                ElevatedButton(
                  onPressed: () => _addToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00563B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.add_shopping_cart, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () async {
            final updated = await Navigator.pushNamed(context, '/cart');
            if (updated == true) {
              setState(() {
                selectedSizes.clear();
              });
            }
          },
        ),
        if (globalCart.isNotEmpty)
          Positioned(
            right: 5,
            top: 5,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                '${globalCart.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
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
            automaticallyImplyLeading: false,
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
                    fontSize: 22,
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
