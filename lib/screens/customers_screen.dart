import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../services/storage_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _storage = StorageService();
  List<Customer> _customers = [];
  List<Order> _orders = [];
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final customers = await _storage.getCustomers();
    final orders = await _storage.getOrders();
    setState(() {
      _customers = customers..sort((a, b) => b.lastOrderAt.compareTo(a.lastOrderAt));
      _orders = orders;
      _loading = false;
    });
  }

  List<Customer> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((c) => 
      c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (c.phone?.contains(_searchQuery) ?? false)
    ).toList();
  }

  List<Order> _getCustomerOrders(String customerId) {
    return _orders.where((o) => o.buyerId == customerId).toList()
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
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

  void _showCustomerDetails(Customer customer) {
    final customerOrders = _getCustomerOrders(customer.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        if (customer.phone != null) Text(customer.phone!, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        if (customer.email != null) Text(customer.email!, style: const TextStyle(color: Colors.grey)),
                        if (customer.address != null) Text(customer.address!, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (customer.phone != null) IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () => _callCustomer(customer.phone!),
                      ),
                      if (customer.phone != null) IconButton(
                        icon: const Icon(Icons.message),
                        onPressed: () => _messageCustomer(customer.phone!),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('${customer.totalOrders}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const Text('Total Orders'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('\$${customer.totalSpent.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const Text('Total Spent'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Order History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: customerOrders.isEmpty
                    ? const Center(child: Text('No orders yet'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: customerOrders.length,
                        itemBuilder: (context, index) {
                          final order = customerOrders[index];
                          return Card(
                            child: ListTile(
                              title: Text('Order #${order.id.substring(0, 8)}'),
                              subtitle: Text('${DateFormat('MMM dd, yyyy').format(order.orderDate)} • ${order.status.toUpperCase()}'),
                              trailing: Text('\$${order.totalAmount.toStringAsFixed(2)}'),
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: _filteredCustomers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(_searchQuery.isEmpty ? 'No customers yet' : 'No customers found'),
                  Text(_searchQuery.isEmpty ? 'Customers will appear here when they place orders' : 'Try a different search term'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = _filteredCustomers[index];
                return Card(
                  margin: const EdgeInsets.all(8),
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
                        if (customer.phone != null) Text(customer.phone!),
                        Text('${customer.totalOrders} orders • \$${customer.totalSpent.toStringAsFixed(2)} spent'),
                        Text('Last order: ${DateFormat('MMM dd, yyyy').format(customer.lastOrderAt)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (customer.phone != null) IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () => _callCustomer(customer.phone!),
                        ),
                        if (customer.phone != null) IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () => _messageCustomer(customer.phone!),
                        ),
                      ],
                    ),
                    onTap: () => _showCustomerDetails(customer),
                  ),
                );
              },
            ),
    );
  }
}