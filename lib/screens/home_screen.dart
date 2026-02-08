import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../models/product.dart';

import '../services/storage_service.dart';
import '../services/push_notification_service.dart';
import '../widgets/safe_image.dart';
import 'vendor_catalog_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final Vendor vendor;
  final Function(int)? onNavigateToTab;
  
  const HomeScreen({super.key, required this.vendor, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  final _notificationService = PushNotificationService();
  List<Product> _products = [];
  List<Vendor> _vendors = [];
  bool _loading = true;
  int _unreadNotifications = 0;
  final _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final allProducts = await _storage.getProducts();
      final allVendors = await _storage.getVendors();
      final unreadCount = await _notificationService.getUnreadCount(widget.vendor.id);
      
      if (mounted) {
        setState(() {
          _products = allProducts.where((p) => p.isAvailable).toList();
          _products.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
          _vendors = allVendors;
          _filteredProducts = _products;
          _unreadNotifications = unreadCount;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _filterProducts() {
    var filtered = _products;
    
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(query) ||
        p.description.toLowerCase().contains(query)
      ).toList();
    }
    
    if (_selectedCategory != null) {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }
    
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
    setState(() => _filteredProducts = filtered);
  }

  Widget _buildMarketplaceProductCard(Product product, Vendor vendor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VendorCatalogScreen(
              vendor: vendor,
              products: _products.where((p) => p.vendorId == vendor.id).toList(),
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
                    child: const Icon(Icons.shopping_bag, size: 50),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'by ${vendor.businessName}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
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
  Widget build(BuildContext context) {
    final categories = _products.map((p) => p.category).toSet().toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace - ${widget.vendor.businessName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationsScreen(userId: widget.vendor.id)),
                  ).then((_) => _loadData());
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: (_) => _filterProducts(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Categories')),
                          ...categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                          _filterProducts();
                        },
                      ),
                    ],
                  ),
                ),
                
                // Products Grid
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? const Center(child: Text('No products available'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            final vendor = _vendors.firstWhere(
                              (v) => v.id == product.vendorId,
                              orElse: () => Vendor(id: '', businessName: 'Unknown', ownerName: '', phone: ''),
                            );
                            return _buildMarketplaceProductCard(product, vendor);
                          },
                        ),
                ),
              ],
            ),
    );
  }


}