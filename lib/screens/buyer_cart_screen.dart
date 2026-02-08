import 'package:flutter/material.dart';
import '../models/buyer.dart';
import 'cart_screen.dart';

class BuyerCartScreen extends StatelessWidget {
  final Buyer? buyer;

  const BuyerCartScreen({super.key, this.buyer});

  @override
  Widget build(BuildContext context) {
    return CartScreen(buyer: buyer);
  }
}
