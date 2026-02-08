import 'package:flutter/material.dart';
import '../models/buyer.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import 'product_detail_screen.dart';

class BuyerCategoriesScreen extends StatefulWidget {
  final Buyer buyer;

  const BuyerCategoriesScreen({super.key, required this.buyer});

  @override
  State<BuyerCategoriesScreen> createState() => _BuyerCategoriesScreenState();
}

class _BuyerCategoriesScreenState extends State<BuyerCategoriesScreen> {
  final _storage = StorageService();
  List<Product> _products = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final products = await _storage.getProducts();
    final categories = products.map((p) => p.category).toSet().toList();
    setState(() {
      _products = products;
      _categories = categories;
      _loading = false;
    });
  }

  List<Product> get _filteredProducts {
    return _selectedCategory == null
        ? _products
        : _products.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Categories Filter
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (_) => setState(() => _selectedCategory = null),
                          ),
                        );
                      }
                      final category = _categories[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (_) => setState(() => _selectedCategory = category),
                        ),
                      );
                    },
                  ),
                ),
                
                // Products Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
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
                                    child: const Center(child: Icon(Icons.shopping_bag, size: 40)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text(product.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}