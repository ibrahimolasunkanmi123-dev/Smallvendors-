import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../services/storage_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _storage = StorageService();
  List<Product> _products = [];
  List<Order> _orders = [];
  List<Customer> _customers = [];
  bool _loading = true;
  String _selectedPeriod = '7 days';
  final List<String> _periods = ['7 days', '30 days', '90 days', 'All time'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final products = await _storage.getProducts();
      final orders = await _storage.getOrders();
      final customers = await _storage.getCustomers();
      
      if (mounted) {
        setState(() {
          _products = products;
          _orders = orders;
          _customers = customers;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double get _totalRevenue => _orders.where((o) => o.status == 'delivered').fold(0.0, (sum, o) => sum + o.totalAmount);
  int get _totalOrders => _orders.length;
  int get _activeCustomers => _customers.length;
  int get _lowStockProducts => _products.where((p) => p.isLowStock).length;

  List<Product> get _topProducts {
    final sorted = List<Product>.from(_products)..sort((a, b) => b.orders.compareTo(a.orders));
    return sorted.take(5).toList();
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
        title: const Text('Analytics'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: 16),
              _buildMetricsCards(),
              const SizedBox(height: 24),
              _buildRevenueChart(),
              const SizedBox(height: 24),
              _buildTopProducts(),
              const SizedBox(height: 24),
              _buildOrderStatusChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard('Total Revenue', '\$${_totalRevenue.toStringAsFixed(2)}', Icons.attach_money, Colors.green),
        _buildMetricCard('Total Orders', _totalOrders.toString(), Icons.shopping_cart, Colors.blue),
        _buildMetricCard('Active Customers', _activeCustomers.toString(), Icons.people, Colors.orange),
        _buildMetricCard('Low Stock Items', _lowStockProducts.toString(), Icons.warning, Colors.red),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (_orders.isEmpty) return const SizedBox();

    final last7Days = List.generate(7, (i) => DateTime.now().subtract(Duration(days: 6 - i)));
    final revenueData = last7Days.map((date) {
      final dayOrders = _orders.where((o) => 
        o.status == 'delivered' &&
        o.completedAt != null &&
        DateFormat('yyyy-MM-dd').format(o.completedAt!) == DateFormat('yyyy-MM-dd').format(date)
      );
      return dayOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Revenue (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < last7Days.length) {
                            return Text(DateFormat('MM/dd').format(last7Days[value.toInt()]));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: revenueData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
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

  Widget _buildTopProducts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_topProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No products available'),
              )
            else
              ..._topProducts.map((product) => ListTile(
                title: Text(product.name),
                subtitle: Text('${product.orders} orders • ${product.views} views'),
                trailing: Text('\$${product.price.toStringAsFixed(2)}'),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: _periods.map((period) => ChoiceChip(
                  label: Text(period),
                  selected: _selectedPeriod == period,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPeriod = period);
                    }
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusChart() {
    if (_orders.isEmpty) return const SizedBox();

    final statusCounts = <String, int>{};
    for (final order in _orders) {
      final status = order.status;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Status Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: statusCounts.entries.map((entry) {
                    final colors = <String, Color>{
                      'pending': Colors.orange,
                      'confirmed': Colors.blue,
                      'preparing': Colors.purple,
                      'ready': Colors.green,
                      'delivered': Colors.teal,
                      'cancelled': Colors.red,
                    };
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: colors[entry.key] ?? Colors.grey,
                      radius: 60,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}