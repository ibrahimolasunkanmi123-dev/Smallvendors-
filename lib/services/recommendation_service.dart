import 'dart:math';
import '../models/product.dart';
import 'storage_service.dart';

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final _storage = StorageService();

  Future<List<Product>> getPersonalizedRecommendations(String buyerId, {int limit = 10}) async {
    final products = await _storage.getProducts();
    final orders = await _storage.getOrders();
    final buyerOrders = orders.where((o) => o.buyerId == buyerId).toList();

    if (buyerOrders.isEmpty) {
      return getTrendingProducts(limit: limit);
    }

    // Get buyer's purchase history
    final purchasedCategories = <String, int>{};
    final purchasedProducts = <String>{};

    for (final order in buyerOrders) {
      for (final item in order.items) {
        purchasedProducts.add(item.productId);
        final product = products.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => Product(id: '', vendorId: '', name: '', description: '', price: 0, category: ''),
        );
        if (product.id.isNotEmpty) {
          purchasedCategories[product.category] = (purchasedCategories[product.category] ?? 0) + 1;
        }
      }
    }

    // Find products in preferred categories that haven't been purchased
    final recommendations = <Product>[];
    final preferredCategories = purchasedCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final categoryEntry in preferredCategories) {
      final categoryProducts = products
        .where((p) => p.category == categoryEntry.key && 
                     !purchasedProducts.contains(p.id) && 
                     p.isAvailable)
        .toList();
      
      // Sort by popularity and rating
      categoryProducts.sort((a, b) => b.orders.compareTo(a.orders));
      recommendations.addAll(categoryProducts.take(3));
    }

    // Fill remaining slots with trending products
    if (recommendations.length < limit) {
      final trending = await getTrendingProducts(limit: limit - recommendations.length);
      for (final product in trending) {
        if (!recommendations.any((r) => r.id == product.id)) {
          recommendations.add(product);
        }
      }
    }

    return recommendations.take(limit).toList();
  }

  Future<List<Product>> getTrendingProducts({int limit = 10}) async {
    final products = await _storage.getProducts();
    
    // Sort by orders (popularity) and views
    final trending = products.where((p) => p.isAvailable).toList();
    trending.sort((a, b) {
      final scoreA = a.orders * 2 + a.views;
      final scoreB = b.orders * 2 + b.views;
      return scoreB.compareTo(scoreA);
    });

    return trending.take(limit).toList();
  }

  Future<List<Product>> getSimilarProducts(String productId, {int limit = 5}) async {
    final products = await _storage.getProducts();
    final targetProduct = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(id: '', vendorId: '', name: '', description: '', price: 0, category: ''),
    );

    if (targetProduct.id.isEmpty) return [];

    // Find products in same category with similar price range
    final priceRange = targetProduct.price * 0.3; // 30% price tolerance
    final similar = products.where((p) => 
      p.id != productId &&
      p.category == targetProduct.category &&
      p.isAvailable &&
      (p.price >= targetProduct.price - priceRange && p.price <= targetProduct.price + priceRange)
    ).toList();

    // Sort by popularity
    similar.sort((a, b) => b.orders.compareTo(a.orders));

    return similar.take(limit).toList();
  }

  Future<List<Product>> getFrequentlyBoughtTogether(String productId, {int limit = 3}) async {
    final orders = await _storage.getOrders();
    final products = await _storage.getProducts();
    
    // Find orders that contain the target product
    final relatedProductCounts = <String, int>{};
    
    for (final order in orders) {
      final hasTargetProduct = order.items.any((item) => item.productId == productId);
      if (hasTargetProduct) {
        for (final item in order.items) {
          if (item.productId != productId) {
            relatedProductCounts[item.productId] = (relatedProductCounts[item.productId] ?? 0) + 1;
          }
        }
      }
    }

    // Sort by frequency and get products
    final sortedRelated = relatedProductCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recommendations = <Product>[];
    for (final entry in sortedRelated.take(limit)) {
      final product = products.firstWhere(
        (p) => p.id == entry.key && p.isAvailable,
        orElse: () => Product(id: '', vendorId: '', name: '', description: '', price: 0, category: ''),
      );
      if (product.id.isNotEmpty) {
        recommendations.add(product);
      }
    }

    return recommendations;
  }

  Future<List<Product>> getNewArrivals({int limit = 10}) async {
    final products = await _storage.getProducts();
    
    // Sort by creation date (newest first)
    final newProducts = products.where((p) => p.isAvailable).toList();
    newProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return newProducts.take(limit).toList();
  }

  Future<List<Product>> getDealsAndOffers({int limit = 10}) async {
    final products = await _storage.getProducts();
    
    // Simulate deals - products with high stock or low orders
    final deals = products.where((p) => 
      p.isAvailable && 
      (p.stock > p.minStock * 3 || p.orders < 5)
    ).toList();

    // Randomize to simulate different deals
    deals.shuffle(Random());

    return deals.take(limit).toList();
  }

  Future<List<Product>> getCategoryRecommendations(String category, {int limit = 10}) async {
    final products = await _storage.getProducts();
    
    final categoryProducts = products
      .where((p) => p.category == category && p.isAvailable)
      .toList();

    // Sort by popularity and rating
    categoryProducts.sort((a, b) => b.orders.compareTo(a.orders));

    return categoryProducts.take(limit).toList();
  }

  Future<RecommendationInsights> getRecommendationInsights(String buyerId) async {
    final orders = await _storage.getOrders();
    final products = await _storage.getProducts();
    final buyerOrders = orders.where((o) => o.buyerId == buyerId).toList();

    if (buyerOrders.isEmpty) {
      return RecommendationInsights(
        topCategories: [],
        averageOrderValue: 0,
        totalOrders: 0,
        preferredPriceRange: 'No data',
        shoppingFrequency: 'New customer',
      );
    }

    // Analyze shopping patterns
    final categorySpending = <String, double>{};
    double totalSpent = 0;
    
    for (final order in buyerOrders) {
      totalSpent += order.totalAmount;
      for (final item in order.items) {
        final product = products.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => Product(id: '', vendorId: '', name: '', description: '', price: 0, category: ''),
        );
        if (product.id.isNotEmpty) {
          categorySpending[product.category] = 
            (categorySpending[product.category] ?? 0) + item.totalPrice;
        }
      }
    }

    final topCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final averageOrderValue = totalSpent / buyerOrders.length;
    
    // Determine preferred price range
    String priceRange;
    if (averageOrderValue < 25) {
      priceRange = 'Budget (Under \$25)';
    } else if (averageOrderValue < 75) {
      priceRange = 'Mid-range (\$25-\$75)';
    } else {
      priceRange = 'Premium (\$75+)';
    }

    // Calculate shopping frequency
    final daysSinceFirstOrder = DateTime.now().difference(buyerOrders.first.orderDate).inDays;
    final frequency = daysSinceFirstOrder > 0 ? buyerOrders.length / (daysSinceFirstOrder / 30) : 0;
    
    String shoppingFrequency;
    if (frequency > 2) {
      shoppingFrequency = 'Frequent shopper';
    } else if (frequency > 0.5) {
      shoppingFrequency = 'Regular customer';
    } else {
      shoppingFrequency = 'Occasional buyer';
    }

    return RecommendationInsights(
      topCategories: topCategories.take(3).map((e) => e.key).toList(),
      averageOrderValue: averageOrderValue,
      totalOrders: buyerOrders.length,
      preferredPriceRange: priceRange,
      shoppingFrequency: shoppingFrequency,
    );
  }
}

class RecommendationInsights {
  final List<String> topCategories;
  final double averageOrderValue;
  final int totalOrders;
  final String preferredPriceRange;
  final String shoppingFrequency;

  RecommendationInsights({
    required this.topCategories,
    required this.averageOrderValue,
    required this.totalOrders,
    required this.preferredPriceRange,
    required this.shoppingFrequency,
  });
}