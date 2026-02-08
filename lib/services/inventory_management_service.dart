import '../models/product.dart';
import '../services/storage_service.dart';
import '../services/push_notification_service.dart';

class InventoryManagementService {
  static final InventoryManagementService _instance = InventoryManagementService._internal();
  factory InventoryManagementService() => _instance;
  InventoryManagementService._internal();

  final _storage = StorageService();
  final _notificationService = PushNotificationService();

  Future<void> updateStock(String productId, int newStock, String vendorId) async {
    final products = await _storage.getProducts();
    final index = products.indexWhere((p) => p.id == productId);
    
    if (index != -1) {
      final oldProduct = products[index];
      final updatedProduct = Product(
        id: oldProduct.id,
        vendorId: oldProduct.vendorId,
        name: oldProduct.name,
        description: oldProduct.description,
        price: oldProduct.price,
        category: oldProduct.category,
        stock: newStock,
        minStock: oldProduct.minStock,
        imagePath: oldProduct.imagePath,
        isAvailable: newStock > 0,
        orders: oldProduct.orders,
        views: oldProduct.views,
        createdAt: oldProduct.createdAt,
      );
      
      products[index] = updatedProduct;
      await _storage.saveProducts(products);

      // Send low stock notification
      if (updatedProduct.isLowStock) {
        await _notificationService.sendLowStockNotification(vendorId, updatedProduct.name);
      }
    }
  }

  Future<List<Product>> getLowStockProducts(String vendorId) async {
    final products = await _storage.getProducts();
    return products.where((p) => p.vendorId == vendorId && p.isLowStock).toList();
  }

  Future<List<Product>> getOutOfStockProducts(String vendorId) async {
    final products = await _storage.getProducts();
    return products.where((p) => p.vendorId == vendorId && p.stock == 0).toList();
  }

  Future<InventoryStats> getInventoryStats(String vendorId) async {
    final products = await _storage.getProducts();
    final vendorProducts = products.where((p) => p.vendorId == vendorId).toList();

    final totalProducts = vendorProducts.length;
    final inStock = vendorProducts.where((p) => p.stock > 0).length;
    final lowStock = vendorProducts.where((p) => p.isLowStock).length;
    final outOfStock = vendorProducts.where((p) => p.stock == 0).length;
    final totalValue = vendorProducts.fold(0.0, (sum, p) => sum + (p.price * p.stock));

    return InventoryStats(
      totalProducts: totalProducts,
      inStock: inStock,
      lowStock: lowStock,
      outOfStock: outOfStock,
      totalValue: totalValue,
    );
  }

  Future<void> bulkUpdateStock(Map<String, int> updates, String vendorId) async {
    for (final entry in updates.entries) {
      await updateStock(entry.key, entry.value, vendorId);
    }
  }

  Future<List<Product>> getTopSellingProducts(String vendorId, {int limit = 10}) async {
    final products = await _storage.getProducts();
    final vendorProducts = products.where((p) => p.vendorId == vendorId).toList();
    
    vendorProducts.sort((a, b) => b.orders.compareTo(a.orders));
    return vendorProducts.take(limit).toList();
  }
}

class InventoryStats {
  final int totalProducts;
  final int inStock;
  final int lowStock;
  final int outOfStock;
  final double totalValue;

  InventoryStats({
    required this.totalProducts,
    required this.inStock,
    required this.lowStock,
    required this.outOfStock,
    required this.totalValue,
  });
}