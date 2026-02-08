import 'package:flutter/material.dart';
import '../models/buyer.dart';
import '../services/cart_service.dart';
import 'enhanced_home_screen.dart';
import 'buyer_categories_screen.dart';
import 'buyer_cart_screen.dart';
import 'buyer_wishlist_screen.dart';
import 'buyer_account_screen.dart';
import 'buyer_chat_list_screen.dart';
import 'buy_sell_browse_screen.dart';
import 'post_request_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  final Buyer buyer;

  const HomeNavigationScreen({super.key, required this.buyer});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;
  final _cartService = CartService();
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  void _loadCartCount() async {
    final count = await _cartService.getItemCount(widget.buyer.id);
    if (mounted) {
      setState(() => _cartItemCount = count);
    }
  }

  List<Widget> get _screens => [
    EnhancedHomeScreen(buyer: widget.buyer),
    BuyerCategoriesScreen(buyer: widget.buyer),
    BuySellBrowseScreen(buyer: widget.buyer),
    BuyerCartScreen(buyer: widget.buyer),
    BuyerWishlistScreen(buyer: widget.buyer),
    BuyerAccountScreen(buyer: widget.buyer),
    BuyerChatListScreen(buyer: widget.buyer),
  ];

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
          if (index == 3) _loadCartCount(); // Refresh cart count when cart tab is selected
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Buy/Sell',
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
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
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
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 2 ? FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostRequestScreen(buyer: widget.buyer)),
        ),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}