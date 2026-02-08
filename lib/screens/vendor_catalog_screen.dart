import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../widgets/safe_image.dart';
import 'product_detail_screen.dart';
import 'vendor_contact_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorCatalogScreen extends StatefulWidget {
  final Vendor vendor;
  final List<Product> products;

  const VendorCatalogScreen({
    super.key,
    required this.vendor,
    required this.products,
  });

  @override
  State<VendorCatalogScreen> createState() => _VendorCatalogScreenState();
}

class _VendorCatalogScreenState extends State<VendorCatalogScreen> {
  final _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  String? _selectedCategory;
  String _sortBy = 'name';
  bool _isGridView = true;
  Set<String> _favoriteProducts = {};
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _showFilters = false;
  final Map<String, int> _cartQuantities = {};

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products.where((p) => p.isAvailable).toList();
    _initializePriceRange();
    _loadFavorites();
    _sortProducts();
  }

  void _initializePriceRange() {
    if (widget.products.isNotEmpty) {
      final prices = widget.products.map((p) => p.price).toList();
      prices.sort();
      _priceRange = RangeValues(prices.first, prices.last);
    }
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites_${widget.vendor.id}') ?? [];
    setState(() => _favoriteProducts = favorites.toSet());
  }

  void _toggleFavorite(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteProducts.contains(productId)) {
        _favoriteProducts.remove(productId);
      } else {
        _favoriteProducts.add(productId);
      }
    });
    await prefs.setStringList('favorites_${widget.vendor.id}', _favoriteProducts.toList());
  }

  void _filterProducts() {
    var filtered = widget.products.where((p) => p.isAvailable).toList();
    
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
    
    filtered = filtered.where((p) => 
      p.price >= _priceRange.start && p.price <= _priceRange.end
    ).toList();
    
    setState(() => _filteredProducts = filtered);
    _sortProducts();
  }

  void _sortProducts() {
    switch (_sortBy) {
      case 'name':
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'popularity':
        _filteredProducts.sort((a, b) => (b.views + b.orders).compareTo(a.views + a.orders));
        break;
      case 'newest':
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    setState(() {});
  }

  void _shareWhatsApp() async {
    final message = 'Check out ${widget.vendor.businessName}\'s products! They have ${widget.products.length} items available.';
    final url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.products.map((p) => p.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vendor.businessName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareWhatsApp,
          ),
        ],
      ),
      body: Column(
        children: [
          // Vendor Info Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue[100],
                  child: widget.vendor.logoPath != null
                      ? ClipOval(
                          child: SafeImage(
                            imagePath: widget.vendor.logoPath!,
                            fallback: Icon(Icons.store, color: Colors.blue[600]),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.store, color: Colors.blue[600]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vendor.businessName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' ${widget.vendor.rating.toStringAsFixed(1)} (${widget.vendor.totalReviews})'),
                        ],
                      ),
                      if (widget.vendor.location != null)
                        Text(
                          widget.vendor.location!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VendorContactScreen(vendor: widget.vendor),
                    ),
                  ),
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          
          // Vendor Statistics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Products', '${widget.products.length}', Icons.inventory),
                _buildStatCard('Transactions', '${widget.vendor.totalTransactions}', Icons.receipt),
                _buildStatCard('Type', widget.vendor.businessType, Icons.business),
              ],
            ),
          ),
          
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All')),
                          ...categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                          _filterProducts();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sort by',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Name')),
                          DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                          DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                          DropdownMenuItem(value: 'popularity', child: Text('Most Popular')),
                          DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                        ],
                        onChanged: (value) {
                          setState(() => _sortBy = value!);
                          _sortProducts();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Advanced Filters
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: widget.products.isNotEmpty ? widget.products.map((p) => p.price).reduce((a, b) => a > b ? a : b) : 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                      _filterProducts();
                    },
                  ),
                  Text('\$${_priceRange.start.round()} - \$${_priceRange.end.round()}'),
                ],
              ),
            ),
          
          // Products Display
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _filteredProducts = widget.products.where((p) => p.isAvailable).toList();
                });
                _filterProducts();
              },
              child: _filteredProducts.isEmpty
                  ? const Center(child: Text('No products available'))
                  : _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return _buildProductCard(product);
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return _buildProductListItem(product);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isFavorite = _favoriteProducts.contains(product.id);
    final isPopular = product.views > 50 || product.orders > 10;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              vendor: widget.vendor,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (isPopular)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Popular',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  if (product.isLowStock && product.stock > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Low Stock',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.stock > 0)
                          GestureDetector(
                            onTap: () => _showQuickAddDialog(product),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    if (product.stock > 0)
                      Text(
                        '${product.stock} in stock',
                        style: TextStyle(
                          color: product.isLowStock ? Colors.orange : Colors.grey[600],
                          fontSize: 12,
                        ),
                      )
                    else
                      const Text(
                        'Out of stock',
                        style: TextStyle(color: Colors.red, fontSize: 12),
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    final isFavorite = _favoriteProducts.contains(product.id);
    final isPopular = product.views > 50 || product.orders > 10;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SafeImage(
                imagePath: product.imagePath,
                fallback: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.shopping_bag),
                ),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              product.stock > 0 ? '${product.stock} in stock' : 'Out of stock',
              style: TextStyle(
                color: product.stock > 0 
                    ? (product.isLowStock ? Colors.orange : Colors.grey[600])
                    : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _toggleFavorite(product.id),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            if (product.stock > 0)
              GestureDetector(
                onTap: () => _showQuickAddDialog(product),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              vendor: widget.vendor,
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickAddDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          int quantity = _cartQuantities[product.id] ?? 1;
          
          return AlertDialog(
            title: Text('Add ${product.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: quantity > 1 ? () {
                        setDialogState(() => quantity--);
                      } : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('$quantity'),
                    ),
                    IconButton(
                      onPressed: quantity < product.stock ? () {
                        setDialogState(() => quantity++);
                      } : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: \$${(product.price * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _cartQuantities[product.id] = quantity);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $quantity ${product.name}(s) to cart'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ],
          );
        },
      ),
    );
  }
}