import 'package:flutter/material.dart';
import '../models/buyer.dart';
import 'enhanced_home_screen.dart';
import 'buyer_categories_screen.dart';
import 'buyer_cart_screen.dart';
import 'buyer_wishlist_screen.dart';
import 'buyer_account_screen.dart';
import 'buyer_chat_list_screen.dart';

class BuyerMainScreen extends StatefulWidget {
  final Buyer buyer;

  const BuyerMainScreen({super.key, required this.buyer});

  @override
  State<BuyerMainScreen> createState() => _BuyerMainScreenState();
}

class _BuyerMainScreenState extends State<BuyerMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      EnhancedHomeScreen(buyer: widget.buyer),
      BuyerCategoriesScreen(buyer: widget.buyer),
      BuyerCartScreen(buyer: widget.buyer),
      BuyerWishlistScreen(buyer: widget.buyer),
      BuyerChatListScreen(buyer: widget.buyer),
      BuyerAccountScreen(buyer: widget.buyer),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }
}