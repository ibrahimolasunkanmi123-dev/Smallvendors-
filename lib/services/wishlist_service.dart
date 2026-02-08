import 'dart:convert';
import '../models/product.dart';
import 'storage_service.dart';

class WishlistService {
  final _storage = StorageService();
  static const String _wishlistKey = 'wishlist';

  Future<List<Product>> getWishlist(String buyerId) async {
    final wishlistData = await _storage.getData('${_wishlistKey}_$buyerId') ?? '[]';
    final wishlistJson = jsonDecode(wishlistData) as List;
    return wishlistJson.map((json) => Product.fromJson(json)).toList();
  }

  Future<void> addToWishlist(String buyerId, Product product) async {
    final wishlist = await getWishlist(buyerId);
    if (!wishlist.any((p) => p.id == product.id)) {
      wishlist.add(product);
      await _saveWishlist(buyerId, wishlist);
    }
  }

  Future<void> removeFromWishlist(String buyerId, String productId) async {
    final wishlist = await getWishlist(buyerId);
    wishlist.removeWhere((p) => p.id == productId);
    await _saveWishlist(buyerId, wishlist);
  }

  Future<bool> isInWishlist(String buyerId, String productId) async {
    final wishlist = await getWishlist(buyerId);
    return wishlist.any((p) => p.id == productId);
  }

  Future<void> _saveWishlist(String buyerId, List<Product> wishlist) async {
    final wishlistJson = wishlist.map((p) => p.toJson()).toList();
    await _storage.saveData('${_wishlistKey}_$buyerId', jsonEncode(wishlistJson));
  }

  Future<int> getWishlistCount(String buyerId) async {
    final wishlist = await getWishlist(buyerId);
    return wishlist.length;
  }
}