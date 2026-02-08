import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';
import '../services/transaction_service.dart';

class TransactionScreen extends StatefulWidget {
  final Vendor vendor;
  final String customerId;
  final String customerName;
  final String? customerPhone;

  const TransactionScreen({
    super.key,
    required this.vendor,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _storage = StorageService();
  final _transactionService = TransactionService();
  List<Product> _products = [];
  final List<TransactionItem> _items = [];
  bool _isLoading = true;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    try {
      final products = await _storage.getProducts();
      if (mounted) {
        setState(() {
          _products = products.where((p) => p.vendorId == widget.vendor.id).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  void _addItem(Product product) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    setState(() {
      if (existingIndex >= 0) {
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: _items[existingIndex].quantity + 1,
        );
      } else {
        _items.add(TransactionItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: 1,
        ));
      }
      _calculateTotal();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _calculateTotal();
    });
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeItem(index);
      return;
    }
    
    setState(() {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _total = _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _completeTransaction() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to the transaction')),
      );
      return;
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vendorId: widget.vendor.id,
      buyerId: widget.customerId,
      buyerName: widget.customerName,
      customerId: widget.customerId,
      customerName: widget.customerName,
      customerPhone: widget.customerPhone,
      items: _items,
      totalAmount: _total,
      total: _total,
      createdAt: DateTime.now(),
      status: TransactionStatus.completed,
    );

    try {
      await _transactionService.saveTransaction(transaction);
      if (mounted) {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Transaction completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text('Error completing transaction: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction - ${widget.customerName}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: _products.isEmpty
                            ? const Center(child: Text('No products available'))
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: _products.length,
                                itemBuilder: (context, index) {
                                  final product = _products[index];
                                  return Card(
                                    child: InkWell(
                                      onTap: () => _addItem(product),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.shopping_bag, size: 40),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              product.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text('\$${product.price.toStringAsFixed(2)}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: _items.isEmpty
                              ? const Center(child: Text('No items added'))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _items.length,
                                  itemBuilder: (context, index) {
                                    final item = _items[index];
                                    return Card(
                                      child: ListTile(
                                        title: Text(item.productName),
                                        subtitle: Text('\$${item.price.toStringAsFixed(2)} each'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () => _updateQuantity(index, item.quantity - 1),
                                            ),
                                            Text('${item.quantity}'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () => _updateQuantity(index, item.quantity + 1),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () => _removeItem(index),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(top: BorderSide(color: Colors.grey[300]!)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: \$${_total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: _items.isEmpty ? null : _completeTransaction,
                                child: const Text('Complete Transaction'),
                              ),
                            ],
                          ),
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