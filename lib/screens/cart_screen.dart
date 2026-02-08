import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/buyer.dart';
import '../services/cart_service.dart';
import '../widgets/safe_image.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Buyer? buyer;

  const CartScreen({super.key, this.buyer});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();
  List<CartItem> _cartItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() async {
    if (widget.buyer != null) {
      final items = await _cartService.getCartItems(widget.buyer!.id);
      setState(() {
        _cartItems = items;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _updateQuantity(String productId, int quantity) async {
    if (widget.buyer != null) {
      await _cartService.updateQuantity(widget.buyer!.id, productId, quantity);
      _loadCartItems();
    }
  }

  void _removeItem(String productId) async {
    if (widget.buyer != null) {
      await _cartService.removeFromCart(widget.buyer!.id, productId);
      _loadCartItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart')),
        );
      }
    }
  }

  double get _totalAmount => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) => _buildCartItem(_cartItems[index]),
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Add some products to get started', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SafeImage(
                imagePath: item.imagePath,
                fallback: Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.shopping_bag)),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: item.quantity > 1 ? () => _updateQuantity(item.productId, item.quantity - 1) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.grey[600],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
                      child: Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => _updateQuantity(item.productId, item.quantity + 1),
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _removeItem(item.productId),
                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('\$${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cartItems.isNotEmpty
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(cartItems: _cartItems, buyer: widget.buyer))).then((_) => _loadCartItems())
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
