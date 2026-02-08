import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/buyer.dart';
import '../services/storage_service.dart';
import '../services/cart_service.dart';
import '../widgets/safe_image.dart';
import 'product_detail_screen.dart';

class BuyerMarketplaceScreen extends StatefulWidget {
  final Buyer buyer;

  const BuyerMarketplaceScreen({super.key, required this.buyer});

  @override
  State<BuyerMarketplaceScreen> createState() => _BuyerMarketplaceScreenState();
}

class _BuyerMarketplaceScreenState extends State<BuyerMarketplaceScreen> {
  final _storage = StorageService();
  final _cartService = CartService();
  final _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String? _selectedCategory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final products = await _storage.getProducts();
    setState(() {
      _products = products.where((p) => p.isAvailable).toList();
      _filteredProducts = _products;
      _loading = false;
    });
  }

  void _filterProducts() {
    var filtered = List<Product>.from(_products);
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        p.category.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    if (_selectedCategory != null) {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }
    
    setState(() => _filteredProducts = filtered);
  }

  void _addToCart(Product product) async {
    await _cartService.addToCart(widget.buyer.id, product);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to cart tab
              if (context.findAncestorStateOfType<State>() != null) {
                // This would trigger parent to switch to cart tab
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final categories = _products.map((p) => p.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Marketplace', style: TextStyle(fontSize: 20)),
            Text(
              'Welcome, ${widget.buyer.name}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (_) => _filterProducts(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list, color: Colors.blue),
                    onSelected: (category) {
                      setState(() => _selectedCategory = category);
                      _filterProducts();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: null, child: Text('All Categories')),
                      ...categories.map((cat) => PopupMenuItem(value: cat, child: Text(cat))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_selectedCategory != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text(_selectedCategory!),
                    onDeleted: () {
                      setState(() => _selectedCategory = null);
                      _filterProducts();
                    },
                    backgroundColor: Colors.blue[100],
                  ),
                ],
              ),
            ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('No products available'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: product,
                buyer: widget.buyer,
              ),
            ),
          );
        },
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
                      maxLines: 1,
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _addToCart(product),
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text('Add', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}