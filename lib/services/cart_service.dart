import 'dart:convert';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'storage_service.dart';

class CartService {
  final _storage = StorageService();
  static const String _cartKey = 'cart_items';

  Future<List<CartItem>> getCartItems(String buyerId) async {
    final cartData = await _storage.getData('${_cartKey}_$buyerId') ?? '[]';
    final cartList = jsonDecode(cartData) as List;
    return cartList.map((json) => CartItem.fromJson(json)).toList();
  }

  Future<void> addToCart(String buyerId, Product product) async {
    final items = await getCartItems(buyerId);
    final existingIndex = items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      items[existingIndex].quantity++;
    } else {
      items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
      ));
    }
    
    await _saveCart(buyerId, items);
  }

  Future<void> removeFromCart(String buyerId, String productId) async {
    final items = await getCartItems(buyerId);
    items.removeWhere((item) => item.productId == productId);
    await _saveCart(buyerId, items);
  }

  Future<void> updateQuantity(String buyerId, String productId, int quantity) async {
    final items = await getCartItems(buyerId);
    final index = items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
      await _saveCart(buyerId, items);
    }
  }

  Future<void> clearCart(String buyerId) async {
    await _storage.saveData('${_cartKey}_$buyerId', '[]');
  }

  Future<int> getItemCount(String buyerId) async {
    final items = await getCartItems(buyerId);
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  Future<void> _saveCart(String buyerId, List<CartItem> items) async {
    await _storage.saveData('${_cartKey}_$buyerId', jsonEncode(items.map((item) => item.toJson()).toList()));
  }
}