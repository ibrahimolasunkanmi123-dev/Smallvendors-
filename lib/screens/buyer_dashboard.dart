import 'package:flutter/material.dart';
import '../models/buyer.dart';
import '../services/cart_service.dart';

import 'cart_screen.dart';
import 'chat_room_screen.dart';
import 'buyer_profile_screen.dart';
import 'buyer_marketplace_screen.dart';

class BuyerDashboard extends StatefulWidget {
  final Buyer buyer;

  const BuyerDashboard({super.key, required this.buyer});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  int _currentIndex = 0;
  final _cartService = CartService();
  int _cartItemCount = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      BuyerMarketplaceScreen(buyer: widget.buyer),
      CartScreen(buyer: widget.buyer),
      const ChatRoomScreen(),
      BuyerProfileScreen(buyer: widget.buyer),
    ];
    _loadCartCount();
  }

  void _loadCartCount() async {
    final count = await _cartService.getItemCount(widget.buyer.id);
    if (mounted) {
      setState(() => _cartItemCount = count);
    }
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
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) _loadCartCount(); // Refresh cart count when viewing cart
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shop',
          ),
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
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}