
import 'dart:math';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';
import 'storage_service.dart';

class AIAnalyticsService {
  static final AIAnalyticsService _instance = AIAnalyticsService._internal();
  factory AIAnalyticsService() => _instance;
  AIAnalyticsService._internal();

  final _storage = StorageService();

  Future<Map<String, dynamic>> generateBusinessInsights() async {
    final products = await _storage.getProducts();
    final orders = await _storage.getOrders();
    final customers = await _storage.getCustomers();

    return {
      'salesTrends': _analyzeSalesTrends(orders),
      'productPerformance': _analyzeProductPerformance(products, orders),
      'customerBehavior': _analyzeCustomerBehavior(customers, orders),
      'inventoryOptimization': _analyzeInventoryOptimization(products),
      'revenueForecasting': _generateRevenueForecasting(orders),
      'marketingInsights': _generateMarketingInsights(products, orders),
      'competitiveAnalysis': _generateCompetitiveAnalysis(products),
      'riskAssessment': _assessBusinessRisks(products, orders),
    };
  }

  Map<String, dynamic> _analyzeSalesTrends(List<Order> orders) {
    final now = DateTime.now();
    final last30Days = orders.where((o) => 
      now.difference(o.orderDate).inDays <= 30).toList();
    final last7Days = orders.where((o) => 
      now.difference(o.orderDate).inDays <= 7).toList();

    final weeklyGrowth = last7Days.length / max(1, last30Days.length - last7Days.length) * 100;
    
    return {
      'weeklyGrowthRate': weeklyGrowth.toStringAsFixed(1),
      'totalOrders30Days': last30Days.length,
      'totalOrders7Days': last7Days.length,
      'averageOrderValue': last30Days.isEmpty ? 0 : 
        last30Days.map((o) => o.totalAmount).reduce((a, b) => a + b) / last30Days.length,
      'peakSalesDay': _findPeakSalesDay(orders),
      'trend': weeklyGrowth > 10 ? 'Growing' : weeklyGrowth > 0 ? 'Stable' : 'Declining',
    };
  }

  Map<String, dynamic> _analyzeProductPerformance(List<Product> products, List<Order> orders) {
    final productSales = <String, int>{};
    final productRevenue = <String, double>{};

    for (final order in orders) {
      for (final item in order.items) {
        productSales[item.productId] = (productSales[item.productId] ?? 0) + item.quantity;
        productRevenue[item.productId] = (productRevenue[item.productId] ?? 0) + 
          (item.price * item.quantity);
      }
    }

    final topProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'topSellingProducts': topProducts.take(5).map((e) => {
        'productId': e.key,
        'productName': products.firstWhere((p) => p.id == e.key, 
          orElse: () => Product(id: '', vendorId: '', name: 'Unknown', 
            description: '', price: 0, category: '')).name,
        'unitsSold': e.value,
        'revenue': productRevenue[e.key] ?? 0,
      }).toList(),
      'underperformingProducts': _findUnderperformingProducts(products, productSales),
      'categoryPerformance': _analyzeCategoryPerformance(products, productSales),
    };
  }

  Map<String, dynamic> _analyzeCustomerBehavior(List<Customer> customers, List<Order> orders) {
    final customerOrders = <String, List<Order>>{};
    for (final order in orders) {
      customerOrders.putIfAbsent(order.buyerId, () => []).add(order);
    }

    final repeatCustomers = customerOrders.values.where((orders) => orders.length > 1).length;
    final avgOrdersPerCustomer = customers.isEmpty ? 0 : 
      orders.length / customers.length;

    return {
      'totalCustomers': customers.length,
      'repeatCustomers': repeatCustomers,
      'customerRetentionRate': customers.isEmpty ? 0 : 
        (repeatCustomers / customers.length * 100).toStringAsFixed(1),
      'averageOrdersPerCustomer': avgOrdersPerCustomer.toStringAsFixed(1),
      'customerLifetimeValue': _calculateCustomerLifetimeValue(customerOrders),
      'churnRisk': _identifyChurnRisk(customerOrders),
    };
  }

  Map<String, dynamic> _analyzeInventoryOptimization(List<Product> products) {
    final lowStockProducts = products.where((p) => p.isLowStock).length;
    final outOfStockProducts = products.where((p) => p.isOutOfStock).length;
    final overstockedProducts = products.where((p) => p.stock > p.minStock * 5).length;

    return {
      'lowStockAlerts': lowStockProducts,
      'outOfStockItems': outOfStockProducts,
      'overstockedItems': overstockedProducts,
      'inventoryTurnoverRate': _calculateInventoryTurnover(products),
      'reorderRecommendations': _generateReorderRecommendations(products),
      'stockOptimizationScore': _calculateStockOptimizationScore(products),
    };
  }

  Map<String, dynamic> _generateRevenueForecasting(List<Order> orders) {
    if (orders.isEmpty) return {'forecast': 0, 'confidence': 'Low'};

    final monthlyRevenue = <int, double>{};
    for (final order in orders) {
      final month = order.orderDate.month;
      monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + order.totalAmount;
    }

    final avgMonthlyRevenue = monthlyRevenue.values.isEmpty ? 0 : 
      monthlyRevenue.values.reduce((a, b) => a + b) / monthlyRevenue.length;

    final growthRate = _calculateGrowthRate(monthlyRevenue);
    final nextMonthForecast = avgMonthlyRevenue * (1 + growthRate);

    return {
      'nextMonthForecast': nextMonthForecast.toStringAsFixed(2),
      'growthRate': (growthRate * 100).toStringAsFixed(1),
      'confidence': monthlyRevenue.length >= 3 ? 'High' : 'Medium',
      'seasonalTrends': _identifySeasonalTrends(monthlyRevenue),
    };
  }

  Map<String, dynamic> _generateMarketingInsights(List<Product> products, List<Order> orders) {
    _analyzeCategoryPerformance(products, {});
    
    return {
      'recommendedPromotions': _suggestPromotions(products, orders),
      'targetCustomerSegments': _identifyTargetSegments(orders),
      'optimalPricingStrategy': _suggestPricingStrategy(products, orders),
      'marketingROI': _calculateMarketingROI(orders),
      'crossSellOpportunities': _identifyCrossSellOpportunities(orders),
    };
  }

  Map<String, dynamic> _generateCompetitiveAnalysis(List<Product> products) {
    final avgPriceByCategory = <String, double>{};
    final categoryCount = <String, int>{};

    for (final product in products) {
      avgPriceByCategory[product.category] = 
        (avgPriceByCategory[product.category] ?? 0) + product.price;
      categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;
    }

    avgPriceByCategory.forEach((category, totalPrice) {
      avgPriceByCategory[category] = totalPrice / categoryCount[category]!;
    });

    return {
      'pricePositioning': _analyzePricePositioning(products, avgPriceByCategory),
      'marketGaps': _identifyMarketGaps(products),
      'competitiveAdvantages': _identifyCompetitiveAdvantages(products),
      'threatAssessment': _assessCompetitiveThreats(products),
    };
  }

  Map<String, dynamic> _assessBusinessRisks(List<Product> products, List<Order> orders) {
    final risks = <String>[];
    final riskLevel = <String, String>{};

    // Inventory risks
    final lowStockCount = products.where((p) => p.isLowStock).length;
    if (lowStockCount > products.length * 0.3) {
      risks.add('High inventory risk - 30%+ products low stock');
      riskLevel['inventory'] = 'High';
    }

    // Revenue concentration risk
    final recentOrders = orders.where((o) => 
      DateTime.now().difference(o.orderDate).inDays <= 30).toList();
    if (recentOrders.length < 5) {
      risks.add('Revenue concentration risk - Low order volume');
      riskLevel['revenue'] = 'Medium';
    }

    return {
      'riskFactors': risks,
      'riskLevels': riskLevel,
      'mitigationStrategies': _suggestMitigationStrategies(risks),
      'overallRiskScore': _calculateOverallRiskScore(products, orders),
    };
  }

  // Helper methods
  String _findPeakSalesDay(List<Order> orders) {
    final dayCount = <int, int>{};
    for (final order in orders) {
      final day = order.orderDate.weekday;
      dayCount[day] = (dayCount[day] ?? 0) + 1;
    }
    
    if (dayCount.isEmpty) return 'No data';
    
    final peakDay = dayCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[peakDay - 1];
  }

  List<Map<String, dynamic>> _findUnderperformingProducts(List<Product> products, Map<String, int> sales) {
    return products.where((p) => (sales[p.id] ?? 0) < 2)
      .map((p) => {'id': p.id, 'name': p.name, 'sales': sales[p.id] ?? 0})
      .toList();
  }

  Map<String, dynamic> _analyzeCategoryPerformance(List<Product> products, Map<String, int> sales) {
    final categoryStats = <String, Map<String, dynamic>>{};
    
    for (final product in products) {
      if (!categoryStats.containsKey(product.category)) {
        categoryStats[product.category] = {'count': 0, 'sales': 0, 'revenue': 0.0};
      }
      categoryStats[product.category]!['count']++;
      categoryStats[product.category]!['sales'] += sales[product.id] ?? 0;
      categoryStats[product.category]!['revenue'] += product.price * (sales[product.id] ?? 0);
    }
    
    return categoryStats;
  }

  double _calculateCustomerLifetimeValue(Map<String, List<Order>> customerOrders) {
    if (customerOrders.isEmpty) return 0;
    
    final totalRevenue = customerOrders.values
      .expand((orders) => orders)
      .map((order) => order.totalAmount)
      .fold(0.0, (sum, amount) => sum + amount);
    
    return totalRevenue / customerOrders.length;
  }

  List<String> _identifyChurnRisk(Map<String, List<Order>> customerOrders) {
    final now = DateTime.now();
    return customerOrders.entries
      .where((entry) => entry.value.isNotEmpty && 
        now.difference(entry.value.last.orderDate).inDays > 60)
      .map((entry) => entry.key)
      .toList();
  }

  double _calculateInventoryTurnover(List<Product> products) {
    if (products.isEmpty) return 0;
    final totalOrders = products.map((p) => p.orders).fold(0, (sum, orders) => sum + orders);
    final avgStock = products.map((p) => p.stock).fold(0, (sum, stock) => sum + stock) / products.length;
    return avgStock > 0 ? totalOrders / avgStock : 0;
  }

  List<Map<String, dynamic>> _generateReorderRecommendations(List<Product> products) {
    return products.where((p) => p.isLowStock)
      .map((p) => {
        'productId': p.id,
        'productName': p.name,
        'currentStock': p.stock,
        'recommendedOrder': p.minStock * 2,
        'priority': p.isOutOfStock ? 'High' : 'Medium',
      }).toList();
  }

  int _calculateStockOptimizationScore(List<Product> products) {
    if (products.isEmpty) return 100;
    final optimalProducts = products.where((p) => 
      p.stock >= p.minStock && p.stock <= p.minStock * 3).length;
    return ((optimalProducts / products.length) * 100).round();
  }

  double _calculateGrowthRate(Map<int, double> monthlyRevenue) {
    if (monthlyRevenue.length < 2) return 0;
    final values = monthlyRevenue.values.toList();
    final recent = values.sublist(max(0, values.length - 3));
    if (recent.length < 2) return 0;
    return (recent.last - recent.first) / recent.first;
  }

  Map<String, String> _identifySeasonalTrends(Map<int, double> monthlyRevenue) {
    // Simplified seasonal analysis
    final trends = <String, String>{};
    monthlyRevenue.forEach((month, revenue) {
      if (month >= 11 || month <= 1) {
        trends['Winter'] = 'Peak season';
      } else if (month >= 6 && month <= 8) {
        trends['Summer'] = 'Moderate season';
      }
    });
    return trends;
  }

  List<String> _suggestPromotions(List<Product> products, List<Order> orders) {
    final suggestions = <String>[];
    
    final slowMoving = products.where((p) => p.orders < 5).length;
    if (slowMoving > 0) {
      suggestions.add('Bundle slow-moving items with popular products');
    }
    
    if (orders.where((o) => DateTime.now().difference(o.orderDate).inDays <= 7).length < 3) {
      suggestions.add('Launch flash sale to boost weekly sales');
    }
    
    return suggestions;
  }

  List<String> _identifyTargetSegments(List<Order> orders) {
    final segments = <String>[];
    
    final highValueOrders = orders.where((o) => o.totalAmount > 100).length;
    if (highValueOrders > orders.length * 0.3) {
      segments.add('Premium customers (high-value orders)');
    }
    
    segments.add('Repeat customers');
    segments.add('Price-sensitive buyers');
    
    return segments;
  }

  Map<String, String> _suggestPricingStrategy(List<Product> products, List<Order> orders) {
    return {
      'strategy': 'Value-based pricing',
      'recommendation': 'Increase prices on high-demand, low-stock items',
      'discount_opportunity': 'Offer 10-15% discount on slow-moving inventory',
    };
  }

  double _calculateMarketingROI(List<Order> orders) {
    // Simplified ROI calculation
    final totalRevenue = orders.map((o) => o.totalAmount).fold(0.0, (sum, amount) => sum + amount);
    const estimatedMarketingCost = 1000; // Placeholder
    return totalRevenue > 0 ? (totalRevenue - estimatedMarketingCost) / estimatedMarketingCost : 0;
  }

  List<String> _identifyCrossSellOpportunities(List<Order> orders) {
    return [
      'Customers who buy electronics often purchase accessories',
      'Food buyers frequently add beverages to their orders',
      'Clothing customers show interest in fashion accessories',
    ];
  }

  Map<String, String> _analyzePricePositioning(List<Product> products, Map<String, double> avgPrices) {
    final positioning = <String, String>{};
    
    for (final product in products) {
      final avgPrice = avgPrices[product.category] ?? product.price;
      if (product.price > avgPrice * 1.2) {
        positioning[product.category] = 'Premium';
      } else if (product.price < avgPrice * 0.8) {
        positioning[product.category] = 'Budget';
      } else {
        positioning[product.category] = 'Competitive';
      }
    }
    
    return positioning;
  }

  List<String> _identifyMarketGaps(List<Product> products) {
    final categories = products.map((p) => p.category).toSet();
    final allCategories = ['Electronics', 'Clothing', 'Food', 'Books', 'Home', 'Sports'];
    
    return allCategories.where((cat) => !categories.contains(cat)).toList();
  }

  List<String> _identifyCompetitiveAdvantages(List<Product> products) {
    return [
      'Diverse product portfolio',
      'Competitive pricing in ${products.isNotEmpty ? products.first.category : "main"} category',
      'Strong inventory management',
    ];
  }

  List<String> _assessCompetitiveThreats(List<Product> products) {
    final threats = <String>[];
    
    if (products.where((p) => p.price > 100).length > products.length * 0.5) {
      threats.add('Price competition from budget alternatives');
    }
    
    threats.add('Market saturation in popular categories');
    
    return threats;
  }

  List<String> _suggestMitigationStrategies(List<String> risks) {
    final strategies = <String>[];
    
    for (final risk in risks) {
      if (risk.contains('inventory')) {
        strategies.add('Implement automated reorder points');
        strategies.add('Diversify supplier base');
      }
      if (risk.contains('revenue')) {
        strategies.add('Expand marketing channels');
        strategies.add('Develop customer retention programs');
      }
    }
    
    return strategies;
  }

  int _calculateOverallRiskScore(List<Product> products, List<Order> orders) {
    int score = 100;
    
    // Inventory risk
    final lowStockRatio = products.isEmpty ? 0 : 
      products.where((p) => p.isLowStock).length / products.length;
    score -= (lowStockRatio * 30).round();
    
    // Revenue risk
    final recentOrders = orders.where((o) => 
      DateTime.now().difference(o.orderDate).inDays <= 30).length;
    if (recentOrders < 10) score -= 20;
    
    return max(0, score);
  }
}