import '../models/product.dart';
import '../models/vendor.dart';
import 'storage_service.dart';

class AdvancedSearchService {
  static final AdvancedSearchService _instance = AdvancedSearchService._internal();
  factory AdvancedSearchService() => _instance;
  AdvancedSearchService._internal();

  final _storage = StorageService();

  Future<SearchResults> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? location,
    bool? inStock,
    double? minRating,
    String? sortBy,
    bool ascending = true,
  }) async {
    final products = await _storage.getProducts();
    final vendors = await _storage.getVendors();
    
    var filteredProducts = products.where((product) {
      // Text search
      if (query != null && query.isNotEmpty) {
        final searchText = query.toLowerCase();
        if (!product.name.toLowerCase().contains(searchText) &&
            !product.description.toLowerCase().contains(searchText) &&
            !product.category.toLowerCase().contains(searchText)) {
          return false;
        }
      }

      // Category filter
      if (category != null && product.category != category) {
        return false;
      }

      // Price range filter
      if (minPrice != null && product.price < minPrice) {
        return false;
      }
      if (maxPrice != null && product.price > maxPrice) {
        return false;
      }

      // Stock filter
      if (inStock == true && product.stock <= 0) {
        return false;
      }

      // Location filter (vendor location)
      if (location != null) {
        final vendor = vendors.firstWhere(
          (v) => v.id == product.vendorId,
          orElse: () => Vendor(
            id: '', ownerName: '', businessName: '', phone: '', 
            businessType: '', location: null,
          ),
        );
        if (vendor.location == null || 
            !vendor.location!.toLowerCase().contains(location.toLowerCase())) {
          return false;
        }
      }

      // Rating filter (vendor rating)
      if (minRating != null) {
        final vendor = vendors.firstWhere(
          (v) => v.id == product.vendorId,
          orElse: () => Vendor(
            id: '', ownerName: '', businessName: '', phone: '', 
            businessType: '', location: null,
          ),
        );
        if (vendor.rating < minRating) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort results
    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          filteredProducts.sort((a, b) => ascending 
            ? a.name.compareTo(b.name) 
            : b.name.compareTo(a.name));
          break;
        case 'price':
          filteredProducts.sort((a, b) => ascending 
            ? a.price.compareTo(b.price) 
            : b.price.compareTo(a.price));
          break;
        case 'rating':
          filteredProducts.sort((a, b) {
            final vendorA = vendors.firstWhere((v) => v.id == a.vendorId, 
              orElse: () => Vendor(id: '', ownerName: '', businessName: '', phone: '', businessType: ''));
            final vendorB = vendors.firstWhere((v) => v.id == b.vendorId, 
              orElse: () => Vendor(id: '', ownerName: '', businessName: '', phone: '', businessType: ''));
            return ascending 
              ? vendorA.rating.compareTo(vendorB.rating)
              : vendorB.rating.compareTo(vendorA.rating);
          });
          break;
        case 'popularity':
          filteredProducts.sort((a, b) => ascending 
            ? a.orders.compareTo(b.orders) 
            : b.orders.compareTo(a.orders));
          break;
      }
    }

    return SearchResults(
      products: filteredProducts,
      totalResults: filteredProducts.length,
      searchQuery: query,
      filters: SearchFilters(
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        location: location,
        inStock: inStock,
        minRating: minRating,
      ),
    );
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.length < 2) return [];

    final products = await _storage.getProducts();
    final suggestions = <String>{};

    for (final product in products) {
      // Add product names that match
      if (product.name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(product.name);
      }
      
      // Add categories that match
      if (product.category.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(product.category);
      }
    }

    return suggestions.take(10).toList();
  }

  Future<List<String>> getPopularSearches() async {
    // In a real app, this would come from analytics
    return [
      'Electronics',
      'Clothing',
      'Food',
      'Books',
      'Home & Garden',
      'Sports',
      'Beauty',
      'Automotive',
    ];
  }

  Future<SearchAnalytics> getSearchAnalytics() async {
    final products = await _storage.getProducts();
    final vendors = await _storage.getVendors();

    final categoryCount = <String, int>{};
    final priceRanges = <String, int>{
      '0-25': 0,
      '25-50': 0,
      '50-100': 0,
      '100+': 0,
    };

    for (final product in products) {
      // Count by category
      categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;

      // Count by price range
      if (product.price <= 25) {
        priceRanges['0-25'] = priceRanges['0-25']! + 1;
      } else if (product.price <= 50) {
        priceRanges['25-50'] = priceRanges['25-50']! + 1;
      } else if (product.price <= 100) {
        priceRanges['50-100'] = priceRanges['50-100']! + 1;
      } else {
        priceRanges['100+'] = priceRanges['100+']! + 1;
      }
    }

    return SearchAnalytics(
      totalProducts: products.length,
      totalVendors: vendors.length,
      categoryDistribution: categoryCount,
      priceDistribution: priceRanges,
      averagePrice: products.isEmpty ? 0 : 
        products.map((p) => p.price).reduce((a, b) => a + b) / products.length,
    );
  }
}

class SearchResults {
  final List<Product> products;
  final int totalResults;
  final String? searchQuery;
  final SearchFilters filters;

  SearchResults({
    required this.products,
    required this.totalResults,
    this.searchQuery,
    required this.filters,
  });
}

class SearchFilters {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? location;
  final bool? inStock;
  final double? minRating;

  SearchFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.location,
    this.inStock,
    this.minRating,
  });
}

class SearchAnalytics {
  final int totalProducts;
  final int totalVendors;
  final Map<String, int> categoryDistribution;
  final Map<String, int> priceDistribution;
  final double averagePrice;

  SearchAnalytics({
    required this.totalProducts,
    required this.totalVendors,
    required this.categoryDistribution,
    required this.priceDistribution,
    required this.averagePrice,
  });
}