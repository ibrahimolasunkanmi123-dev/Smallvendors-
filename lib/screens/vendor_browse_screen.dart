import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../widgets/safe_image.dart';
import 'vendor_catalog_screen.dart';

class VendorBrowseScreen extends StatefulWidget {
  const VendorBrowseScreen({super.key});

  @override
  State<VendorBrowseScreen> createState() => _VendorBrowseScreenState();
}

class _VendorBrowseScreenState extends State<VendorBrowseScreen> {
  final _storage = StorageService();
  final _searchController = TextEditingController();
  List<Vendor> _vendors = [];
  List<Vendor> _filteredVendors = [];
  Map<String, List<Product>> _vendorProducts = {};
  String? _selectedCategory;
  double _minRating = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  void _loadVendors() async {
    final vendors = await _storage.getVendors();
    final products = await _storage.getProducts();
    
    final vendorProductMap = <String, List<Product>>{};
    for (final product in products) {
      vendorProductMap.putIfAbsent(product.vendorId, () => []).add(product);
    }
    
    setState(() {
      _vendors = vendors;
      _filteredVendors = vendors;
      _vendorProducts = vendorProductMap;
      _loading = false;
    });
  }

  void _filterVendors() {
    var filtered = List<Vendor>.from(_vendors);
    
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((v) => 
        v.businessName.toLowerCase().contains(query) ||
        v.businessType.toLowerCase().contains(query) ||
        (v.location?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    if (_selectedCategory != null) {
      filtered = filtered.where((v) => v.businessType == _selectedCategory).toList();
    }
    
    if (_minRating > 0) {
      filtered = filtered.where((v) => v.rating >= _minRating).toList();
    }
    
    setState(() => _filteredVendors = filtered);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final categories = _vendors.map((v) => v.businessType).where((t) => t.isNotEmpty).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Vendors'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search vendors by name, type, or location...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (_) => _filterVendors(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Categories')),
                          ...categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                          _filterVendors();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Min Rating: ${_minRating.toStringAsFixed(1)}'),
                          Slider(
                            value: _minRating,
                            min: 0.0,
                            max: 5.0,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() => _minRating = value);
                              _filterVendors();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredVendors.isEmpty
                ? const Center(child: Text('No vendors found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredVendors.length,
                    itemBuilder: (context, index) {
                      final vendor = _filteredVendors[index];
                      final products = _vendorProducts[vendor.id] ?? [];
                      return _buildVendorCard(vendor, products);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor, List<Product> products) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VendorCatalogScreen(vendor: vendor, products: products),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: vendor.logoPath != null
                        ? ClipOval(
                            child: SafeImage(
                              imagePath: vendor.logoPath!,
                              fallback: Icon(Icons.store, size: 30, color: Colors.blue[600]),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.store, size: 30, color: Colors.blue[600]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.businessName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (vendor.businessType.isNotEmpty)
                          Text(
                            vendor.businessType,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        if (vendor.location != null)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vendor.location!,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            vendor.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${vendor.totalReviews} reviews',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${products.length} products available',
                style: TextStyle(color: Colors.grey[700]),
              ),
              if (products.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.take(5).length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SafeImage(
                            imagePath: product.imagePath,
                            fallback: Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.shopping_bag, size: 20),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}