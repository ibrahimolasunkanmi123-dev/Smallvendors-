import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/buyer.dart';
import '../models/notification.dart';
import '../models/order.dart';
import '../services/cart_service.dart';
import '../services/storage_service.dart';
import '../services/push_notification_service.dart';
import 'buyer_order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Buyer? buyer;

  const CheckoutScreen({super.key, required this.cartItems, this.buyer});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _storage = StorageService();
  final _notificationService = PushNotificationService();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.buyer?.address ?? '';
  }

  void _placeOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final orders = await _storage.getOrders();
      final newOrder = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        buyerId: widget.buyer?.id ?? '',
        vendorId: widget.cartItems.first.product.vendorId,
        items: widget.cartItems,
        status: 'pending',
        totalAmount: widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice),
        orderDate: DateTime.now(),
        deliveryAddress: _addressController.text,
        paymentMethod: _paymentMethod,
        notes: _notesController.text,
      );

      orders.add(newOrder);
      await _storage.saveOrders(orders);

      if ((widget.buyer?.id ?? '').isNotEmpty) {
        await _notificationService.sendNotification(
          userId: widget.buyer!.id,
          title: 'Order placed successfully',
          message: 'Order #${newOrder.id.substring(0, 8)} is now being processed.',
          type: NotificationType.order,
          actionData: newOrder.id,
        );
      }

      if (widget.buyer != null) {
        await CartService().clearCart(widget.buyer!.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        if (widget.buyer != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BuyerOrderHistoryScreen(buyer: widget.buyer!),
            ),
          );
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final deliveryFee = 5.0;
    final grandTotal = total + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    title: Text(item.productName),
                    subtitle: Text('\$${item.price.toStringAsFixed(2)} x ${item.quantity}'),
                    trailing: Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Delivery Address
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Enter your delivery address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      _paymentMethod == 'Cash on Delivery' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: _paymentMethod == 'Cash on Delivery' ? Colors.blue : Colors.grey,
                    ),
                    title: const Text('Cash on Delivery'),
                    subtitle: const Text('Pay when your order arrives'),
                    onTap: () => setState(() => _paymentMethod = 'Cash on Delivery'),
                  ),
                  ListTile(
                    leading: Icon(
                      _paymentMethod == 'Bank Transfer' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: _paymentMethod == 'Bank Transfer' ? Colors.blue : Colors.grey,
                    ),
                    title: const Text('Bank Transfer'),
                    subtitle: const Text('Transfer to vendor account'),
                    onTap: () => setState(() => _paymentMethod = 'Bank Transfer'),
                  ),
                  ListTile(
                    leading: Icon(
                      _paymentMethod == 'Mobile Money' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: _paymentMethod == 'Mobile Money' ? Colors.blue : Colors.grey,
                    ),
                    title: const Text('Mobile Money'),
                    subtitle: const Text('Pay via mobile money'),
                    onTap: () => setState(() => _paymentMethod = 'Mobile Money'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Notes
            const Text(
              'Order Notes (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Any special instructions for the vendor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Price Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('\$${total.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Fee:'),
                        Text('\$${deliveryFee.toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Place Order',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
