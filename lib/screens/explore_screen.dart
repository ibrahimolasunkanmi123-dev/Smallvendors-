import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/vendor.dart';
import '../services/storage_service.dart';
import '../widgets/safe_image.dart';
import 'product_detail_screen.dart';
import 'vendor_catalog_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  final _storage = StorageService();
  List<Product> _products = [];
  List<Vendor> _vendors = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() async {
    final products = await _storage.getProducts();
    final vendors = await _storage.getVendors();
    final categories = products.map((p) => p.category).toSet().toList();
    
    setState(() {
      _products = products.where((p) => p.isAvailable).toList();
      _vendors = vendors;
      _categories = ['All', ...categories];
      _loading = false;
    });
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'All') return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Explore'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.explore, size: 80, color: Colors.white54),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Products', icon: Icon(Icons.shopping_bag)),
                Tab(text: 'Categories', icon: Icon(Icons.category)),
                Tab(text: 'Vendors', icon: Icon(Icons.store)),
              ],
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildProductsTab(),
                  _buildCategoriesTab(),
                  _buildVendorsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) => _buildProductCard(_filteredProducts[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final categoryGroups = <String, List<Product>>{};
    for (final product in _products) {
      categoryGroups.putIfAbsent(product.category, () => []).add(product);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categoryGroups.length,
      itemBuilder: (context, index) {
        final category = categoryGroups.keys.elementAt(index);
        final products = categoryGroups[category]!;
        return _buildCategorySection(category, products);
      },
    );
  }

  Widget _buildCategorySection(String category, List<Product> products) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text('${products.length} items'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.take(5).length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SafeImage(
                              imagePath: product.imagePath,
                              fallback: Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.shopping_bag),
                              ),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vendors.length,
      itemBuilder: (context, index) => _buildVendorCard(_vendors[index]),
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    final vendorProducts = _products.where((p) => p.vendorId == vendor.id).toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(Icons.store, color: Theme.of(context).primaryColor),
        ),
        title: Text(vendor.businessName),
        subtitle: Text('${vendorProducts.length} products • ${vendor.location}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VendorCatalogScreen(
              vendor: vendor,
              products: vendorProducts,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final vendor = _vendors.firstWhere((v) => v.id == product.vendorId);
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              vendor: vendor,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SafeImage(
                  imagePath: product.imagePath,
                  fallback: Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.shopping_bag, size: 40),
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      vendor.businessName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}