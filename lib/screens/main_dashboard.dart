import 'package:flutter/material.dart';
import '../models/vendor.dart';
import 'home_screen.dart';
import 'inventory_screen.dart';
import 'orders_screen.dart';
import 'analytics_screen.dart';
import 'customer_management_screen.dart';
import 'settings_screen.dart';

class MainDashboard extends StatefulWidget {
  final Vendor vendor;
  
  const MainDashboard({super.key, required this.vendor});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0; // Home screen with advanced product display
  
  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(vendor: widget.vendor, onNavigateToTab: navigateToTab),
      const InventoryScreen(),
      const OrdersScreen(),
      const AnalyticsScreen(),
      const CustomerManagementScreen(),
      SettingsScreen(vendor: widget.vendor),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}