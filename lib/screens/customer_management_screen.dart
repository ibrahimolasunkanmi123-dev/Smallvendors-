import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/buyer.dart';
import '../models/order.dart';
import '../services/storage_service.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final _storage = StorageService();
  List<Buyer> _customers = [];
  List<Order> _orders = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final customers = await _storage.getBuyers();
    final orders = await _storage.getOrders();
    setState(() {
      _customers = customers;
      _orders = orders;
      _loading = false;
    });
  }

  List<Buyer> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((c) => 
      c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (c.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  int _getCustomerOrderCount(String customerId) {
    return _orders.where((o) => o.buyerId == customerId).length;
  }

  double _getCustomerTotalSpent(String customerId) {
    return _orders
        .where((o) => o.buyerId == customerId && o.status == OrderStatus.delivered)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _filteredCustomers.isEmpty
                ? const Center(child: Text('No customers found'))
                : ListView.builder(
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      final orderCount = _getCustomerOrderCount(customer.id);
                      final totalSpent = _getCustomerTotalSpent(customer.id);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(customer.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customer.email != null) Text(customer.email!),
                              if (customer.phone != null) Text(customer.phone!),
                              Text('$orderCount orders • \$${totalSpent.toStringAsFixed(2)} spent'),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Text('View Orders'),
                                onTap: () => _showCustomerOrders(customer),
                              ),
                              PopupMenuItem(
                                child: const Text('Contact'),
                                onTap: () => _contactCustomer(customer),
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
    );
  }

  void _showCustomerOrders(Buyer customer) {
    final customerOrders = _orders.where((o) => o.buyerId == customer.id).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '${customer.name}\'s Orders',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: customerOrders.length,
                  itemBuilder: (context, index) {
                    final order = customerOrders[index];
                    return Card(
                      child: ListTile(
                        title: Text('Order #${order.id.substring(0, 8)}'),
                        subtitle: Text(
                          '\$${order.totalAmount.toStringAsFixed(2)} • ${DateFormat('MMM dd').format(order.orderDate)}'
                        ),
                        trailing: Chip(
                          label: Text(order.status.toUpperCase()),
                          backgroundColor: _getStatusColor(order.status),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _contactCustomer(Buyer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${customer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customer.phone != null)
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(customer.phone!),
                onTap: () {
                  Navigator.pop(context);
                  // Launch phone call
                },
              ),
            if (customer.email != null)
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(customer.email!),
                onTap: () {
                  Navigator.pop(context);
                  // Launch email
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
      default: return Colors.blue;
    }
  }
}