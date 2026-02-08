import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
// import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/storage_service.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _storage = StorageService();
  final _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _sortBy = 'name';
  bool _sortAscending = true;
  String? _filterCategory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final products = await _storage.getProducts();
    setState(() {
      _products = products;
      _filteredProducts = products;
      _loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<Product>.from(_products);

    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        p.category.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    if (_filterCategory != null) {
      filtered = filtered.where((p) => p.category == _filterCategory).toList();
    }

    filtered.sort((a, b) {
      int result;
      switch (_sortBy) {
        case 'name': result = a.name.compareTo(b.name); break;
        case 'price': result = a.price.compareTo(b.price); break;
        case 'stock': result = a.stock.compareTo(b.stock); break;
        case 'category': result = a.category.compareTo(b.category); break;
        default: result = 0;
      }
      return _sortAscending ? result : -result;
    });

    setState(() => _filteredProducts = filtered);
  }

  void _exportToCsv() async {
    final csvData = [
      ['Name', 'Description', 'Price', 'Category', 'Stock', 'Available'],
      ..._products.map((p) => [
        p.name, p.description, p.price.toString(), p.category, 
        p.stock.toString(), p.isAvailable.toString()
      ])
    ];
    
    final csv = const ListToCsvConverter().convert(csvData);
    
    try {
      // File picker temporarily disabled for build
      String? outputFile = 'inventory_${DateTime.now().millisecondsSinceEpoch}.csv';
      
      if (outputFile.isNotEmpty) {
        final file = File(outputFile);
        await file.writeAsString(csv);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inventory exported successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _bulkUpdateStock() {
    final selectedProducts = <String>{};
    final stockController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Bulk Stock Update'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(
                    labelText: 'New Stock Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Select products:'),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return CheckboxListTile(
                        title: Text(product.name),
                        subtitle: Text('Current: ${product.stock}'),
                        value: selectedProducts.contains(product.id),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedProducts.add(product.id);
                            } else {
                              selectedProducts.remove(product.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedProducts.isEmpty || stockController.text.isEmpty
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final newStock = int.tryParse(stockController.text) ?? 0;
                      for (final productId in selectedProducts) {
                        final index = _products.indexWhere((p) => p.id == productId);
                        if (index != -1) {
                          _products[index] = _products[index].copyWith(stock: newStock);
                        }
                      }
                      await _storage.saveProducts(_products);
                      if (mounted) {
                        navigator.pop();
                        _loadProducts();
                        messenger.showSnackBar(
                          SnackBar(content: Text('Updated ${selectedProducts.length} products')),
                        );
                      }
                    },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final categories = _products.map((p) => p.category).toSet().toList();
    final lowStockCount = _products.where((p) => p.isLowStock).length;
    final outOfStockCount = _products.where((p) => p.isOutOfStock).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToCsv,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _bulkUpdateStock,
                child: const Text('Bulk Update Stock'),
              ),
              PopupMenuItem(
                onTap: () {},
                child: const Text('Import from CSV'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (lowStockCount > 0 || outOfStockCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$lowStockCount low stock, $outOfStockCount out of stock',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (category) {
                    setState(() => _filterCategory = category);
                    _applyFilters();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: null, child: Text('All Categories')),
                    ...categories.map((cat) => PopupMenuItem(value: cat, child: Text(cat))),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (sortBy) {
                    setState(() {
                      if (_sortBy == sortBy) {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortBy = sortBy;
                        _sortAscending = true;
                      }
                    });
                    _applyFilters();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                    const PopupMenuItem(value: 'price', child: Text('Sort by Price')),
                    const PopupMenuItem(value: 'stock', child: Text('Sort by Stock')),
                    const PopupMenuItem(value: 'category', child: Text('Sort by Category')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: product.isLowStock ? Colors.red : Colors.green,
                            child: Text(
                              product.stock.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('\$${product.price.toStringAsFixed(2)} • ${product.category}'),
                              if (product.isLowStock)
                                const Text('Low Stock', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: product.isAvailable,
                                onChanged: (value) async {
                                  final updatedProduct = product.copyWith(isAvailable: value);
                                  final index = _products.indexWhere((p) => p.id == product.id);
                                  _products[index] = updatedProduct;
                                  await _storage.saveProducts(_products);
                                  _applyFilters();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProductScreen(
                                        product: product,
                                        allProducts: _products,
                                      ),
                                    ),
                                  );
                                  if (result == true) _loadProducts();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          _loadProducts();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}