import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardMetrics extends StatelessWidget {
  final double todayRevenue;
  final double weekRevenue;
  final double monthRevenue;
  final int totalOrders;
  final int pendingOrders;
  final int lowStockItems;
  final List<double> weeklyData;

  const DashboardMetrics({
    super.key,
    required this.todayRevenue,
    required this.weekRevenue,
    required this.monthRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.lowStockItems,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMetricCards(),
        const SizedBox(height: 16),
        _buildRevenueChart(),
      ],
    );
  }

  Widget _buildMetricCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Today',
            '\$${todayRevenue.toStringAsFixed(2)}',
            Icons.today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Orders',
            '$totalOrders',
            Icons.shopping_cart,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Pending',
            '$pendingOrders',
            Icons.pending,
            pendingOrders > 0 ? Colors.orange : Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Low Stock',
            '$lowStockItems',
            Icons.warning,
            lowStockItems > 0 ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Revenue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyData.asMap().entries.map((e) => 
                        FlSpot(e.key.toDouble(), e.value)
                      ).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
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