import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../models/buyer.dart';
import '../services/cart_service.dart';
import 'buyer_marketplace_screen.dart';
import 'buyer_categories_screen.dart';
import 'cart_screen.dart';
import 'buyer_wishlist_screen.dart';
import 'buyer_account_screen.dart';
import 'chat_room_screen.dart';
import 'vendor_dashboard.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'analytics_screen.dart';
import 'account_screen.dart';

class MainScreen extends StatefulWidget {
  final Vendor? vendor;
  final Buyer? buyer;
  
  const MainScreen({super.key, this.vendor, this.buyer});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final _cartService = CartService();
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  void _loadCartCount() async {
    if (widget.buyer != null) {
      final count = await _cartService.getItemCount(widget.buyer!.id);
      setState(() => _cartItemCount = count);
    }
  }

  List<Widget> get _screens {
    if (widget.buyer != null) {
      return [
        BuyerMarketplaceScreen(buyer: widget.buyer!),
        BuyerCategoriesScreen(buyer: widget.buyer!),
        CartScreen(buyer: widget.buyer),
        BuyerWishlistScreen(buyer: widget.buyer!),
        BuyerAccountScreen(buyer: widget.buyer),
        ChatRoomScreen(buyer: widget.buyer),
      ];
    }
    return [
      _buildVendorHome(),
      _buildVendorProducts(),
      _buildVendorOrders(),
      _buildVendorAnalytics(),
      _buildVendorAccount(),
      ChatRoomScreen(vendor: widget.vendor),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2 && widget.buyer != null) _loadCartCount();
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: widget.buyer != null ? _buyerNavItems : _vendorNavItems,
      ),
    );
  }

  List<BottomNavigationBarItem> get _buyerNavItems => [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    const BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
    BottomNavigationBarItem(
      icon: Stack(
        children: [
          const Icon(Icons.shopping_cart),
          if (_cartItemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text('$_cartItemCount', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
      label: 'Cart',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
    const BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
    const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
  ];

  List<BottomNavigationBarItem> get _vendorNavItems => const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Products'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
  ];

  Widget _buildVendorHome() => VendorDashboard(vendor: widget.vendor!);

  Widget _buildVendorProducts() => const ProductsScreen();

  Widget _buildVendorOrders() => const OrdersScreen();

  Widget _buildVendorAnalytics() => const AnalyticsScreen();

  Widget _buildVendorAccount() => const AccountScreen();
}