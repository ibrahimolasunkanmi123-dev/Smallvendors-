import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';
import '../models/buyer.dart';
import '../services/storage_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _storage = StorageService();
  List<Order> _orders = [];
  String? _filterStatus;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final orders = await _storage.getOrders();
    setState(() {
      _orders = orders..sort((a, b) => b.orderDate.compareTo(a.orderDate));
      _loading = false;
    });
  }

  List<Order> get _filteredOrders {
    if (_filterStatus == null) return _orders;
    return _orders.where((o) => o.status == _filterStatus).toList();
  }

  void _updateOrderStatus(Order order, String newStatus) async {
    final updatedOrder = order.copyWith(
      status: newStatus,
      completedAt: newStatus == 'delivered' ? DateTime.now() : order.completedAt,
    );

    final index = _orders.indexWhere((o) => o.id == order.id);
    _orders[index] = updatedOrder;
    await _storage.saveOrders(_orders);
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${newStatus.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<Buyer?> _getBuyer(String buyerId) async {
    final buyers = await _storage.getBuyers();
    try {
      return buyers.firstWhere((b) => b.id == buyerId);
    } catch (e) {
      return null;
    }
  }

  void _callCustomer(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _messageCustomer(String phone) async {
    final url = 'sms:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.purple;
      case 'ready': return Colors.green;
      case 'delivered': return Colors.teal;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) => setState(() => _filterStatus = status),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Orders')),
              ...OrderStatus.all.map((status) => PopupMenuItem(
                value: status,
                child: Text(status.toUpperCase()),
              )),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOrderStats(),
          Expanded(
            child: _filteredOrders.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Orders will appear here when customers place them'),
                      ],
                    ),
                  )
          : ListView.builder(
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order.status),
                      child: Text(
                        order.status[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text('Order #${order.id.substring(0, 8)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<Buyer?>(
                          future: _getBuyer(order.buyerId),
                          builder: (context, snapshot) {
                            final buyer = snapshot.data;
                            return Text(buyer?.name ?? 'Unknown Customer');
                          },
                        ),
                        Text('\$${order.totalAmount.toStringAsFixed(2)} • ${DateFormat('MMM dd, yyyy').format(order.orderDate)}'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Buyer?>(
                              future: _getBuyer(order.buyerId),
                              builder: (context, snapshot) {
                                final buyer = snapshot.data;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Customer: ${buyer?.name ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          if (buyer?.phone != null) Text('Phone: ${buyer!.phone}'),
                                          Text('Address: ${order.deliveryAddress}'),
                                          Text('Payment: ${order.paymentMethod}'),
                                          if (order.notes != null && order.notes!.isNotEmpty) 
                                            Text('Notes: ${order.notes}'),
                                        ],
                                      ),
                                    ),
                                    if (buyer?.phone != null)
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.phone),
                                            onPressed: () => _callCustomer(buyer!.phone!),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.message),
                                            onPressed: () => _messageCustomer(buyer!.phone!),
                                          ),
                                        ],
                                      ),
                                  ],
                                );
                              },
                            ),
                            const Divider(),
                            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text('${item.productName} x${item.quantity}')),
                                  Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                                ],
                              ),
                            )),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: OrderStatus.all.map((status) {
                                final isSelected = order.status == status;
                                return FilterChip(
                                  label: Text(status.toUpperCase()),
                                  selected: isSelected,
                                  onSelected: isSelected ? null : (_) => _updateOrderStatus(order, status),
                                  selectedColor: _getStatusColor(status).withValues(alpha: 0.3),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStats() {
    final statusCounts = <String, int>{};
    for (final status in OrderStatus.all) {
      statusCounts[status] = _orders.where((o) => o.status == status).length;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatChip('Pending', statusCounts[OrderStatus.pending] ?? 0, Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatChip('Ready', statusCounts[OrderStatus.ready] ?? 0, Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatChip('Delivered', statusCounts[OrderStatus.delivered] ?? 0, Colors.teal),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
