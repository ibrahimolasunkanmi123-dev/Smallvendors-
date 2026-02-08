import 'package:flutter/material.dart';
import '../models/buyer.dart';
import '../models/product.dart';
import '../models/vendor.dart';
import '../services/storage_service.dart';
import 'product_detail_screen.dart';
import 'vendor_profile_screen.dart';
import 'post_request_screen.dart';
import '../models/buy_sell_request.dart';

class EnhancedHomeScreen extends StatefulWidget {
  final Buyer buyer;

  const EnhancedHomeScreen({super.key, required this.buyer});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  final _storage = StorageService();
  final _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Vendor> _vendors = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _loading = true;
  bool _showSidebar = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final products = await _storage.getProducts();
    final vendors = await _storage.getVendors();
    final categories = products.map((p) => p.category).toSet().toList();
    
    setState(() {
      _products = products;
      _filteredProducts = products;
      _vendors = vendors;
      _categories = categories;
      _loading = false;
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _filteredProducts = _products.where((p) {
        final matchesQuery = query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == null || p.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _filteredProducts = _products.where((p) {
        final matchesQuery = _searchController.text.isEmpty || 
            p.name.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = category == null || p.category == category;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  List<Product> get _productsSortedByName {
    final sorted = List<Product>.from(_filteredProducts);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${widget.buyer.name}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_showSidebar ? Icons.close : Icons.sort_by_alpha),
            onPressed: () => setState(() => _showSidebar = !_showSidebar),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left Sidebar
                if (_showSidebar)
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: const Border(right: BorderSide(color: Colors.grey)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Products A-Z', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _productsSortedByName.length,
                            itemBuilder: (context, index) {
                              final product = _productsSortedByName[index];
                              return ListTile(
                                dense: true,
                                title: Text(product.name, style: const TextStyle(fontSize: 14)),
                                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product, buyer: widget.buyer)),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        TextField(
                          controller: _searchController,
                          onChanged: _searchProducts,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => PostRequestScreen(
                                    buyer: widget.buyer,
                                    initialType: RequestType.buy,
                                  )),
                                ),
                                icon: const Icon(Icons.search, color: Colors.white),
                                label: const Text('Looking to Buy', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => PostRequestScreen(
                                    buyer: widget.buyer,
                                    initialType: RequestType.sell,
                                  )),
                                ),
                                icon: const Icon(Icons.sell, color: Colors.white),
                                label: const Text('Looking to Sell', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Category Filter
                        Row(
                          children: [
                            const Text('Categories: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('All'),
                                      selected: _selectedCategory == null,
                                      onSelected: (_) => _filterByCategory(null),
                                    ),
                                    const SizedBox(width: 8),
                                    ..._categories.map((category) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        label: Text(category),
                                        selected: _selectedCategory == category,
                                        onSelected: (_) => _filterByCategory(category),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Featured Vendors
                        const Text('Featured Vendors', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _vendors.length,
                            itemBuilder: (context, index) {
                              final vendor = _vendors[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => VendorProfileScreen(vendor: vendor, buyer: widget.buyer)),
                                ),
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.green,
                                        child: Text(vendor.businessName[0], style: const TextStyle(color: Colors.white, fontSize: 20)),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(vendor.businessName, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Products
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Products (${_filteredProducts.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            if (_selectedCategory != null)
                              Chip(
                                label: Text(_selectedCategory!),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => _filterByCategory(null),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product, buyer: widget.buyer)),
                              ),
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                        ),
                                        child: Stack(
                                          children: [
                                            const Center(child: Icon(Icons.shopping_bag, size: 40)),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  product.category,
                                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 16)),
                                          Text('Stock: ${product.stock}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}