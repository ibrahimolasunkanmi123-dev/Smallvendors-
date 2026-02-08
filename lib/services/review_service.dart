import '../models/review.dart';
import '../models/enums.dart';
import '../models/vendor.dart';
import '../models/customer.dart';
import 'storage_service.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final _storage = StorageService();

  Future<List<Review>> getReviewsForTarget(String targetId, ReviewType type) async {
    final reviews = await _storage.getReviews();
    return reviews.where((r) => r.targetId == targetId && r.type == type).toList();
  }

  Future<RatingStats> getRatingStats(String targetId, ReviewType type) async {
    final reviews = await getReviewsForTarget(targetId, type);
    return RatingStats.fromReviews(reviews);
  }

  Future<void> addReview(Review review) async {
    final reviews = await _storage.getReviews();
    reviews.add(review);
    await _storage.saveReviews(reviews);
    await _updateRatings(review.targetId, review.type);
  }

  Future<void> _updateRatings(String targetId, ReviewType type) async {
    final reviews = await getReviewsForTarget(targetId, type);
    if (reviews.isEmpty) return;
    
    final avgRating = reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
    
    if (type == ReviewType.vendor) {
      final vendors = await _storage.getVendors();
      final index = vendors.indexWhere((v) => v.id == targetId);
      if (index != -1) {
        final updated = Vendor(
          id: vendors[index].id,
          businessName: vendors[index].businessName,
          ownerName: vendors[index].ownerName,
          phone: vendors[index].phone,
          businessType: vendors[index].businessType,
          location: vendors[index].location,
          logoPath: vendors[index].logoPath,
          rating: avgRating,
          totalReviews: reviews.length,
          totalTransactions: vendors[index].totalTransactions,
        );
        vendors[index] = updated;
        await _saveVendors(vendors);
      }
    } else if (type == ReviewType.order) {
      final customers = await _storage.getCustomers();
      final index = customers.indexWhere((c) => c.id == targetId);
      if (index != -1) {
        final updated = Customer(
          id: customers[index].id,
          name: customers[index].name,
          phone: customers[index].phone,
          email: customers[index].email,
          address: customers[index].address,
          createdAt: customers[index].createdAt,
          lastOrderAt: customers[index].lastOrderAt,
          totalOrders: customers[index].totalOrders,
          totalSpent: customers[index].totalSpent,
          rating: avgRating,
          totalReviews: reviews.length,
        );
        customers[index] = updated;
        await _storage.saveCustomers(customers);
      }
    }
  }

  Future<bool> hasUserReviewed(String reviewerId, String targetId, String? orderId) async {
    final reviews = await _storage.getReviews();
    return reviews.any((r) => 
      r.reviewerId == reviewerId && 
      r.targetId == targetId && 
      (orderId == null || r.orderId == orderId)
    );
  }

  Future<bool> hasUserReviewedTransaction(String reviewerId, String transactionId) async {
    final reviews = await _storage.getReviews();
    return reviews.any((r) => r.reviewerId == reviewerId && r.transactionId == transactionId);
  }

  Future<void> _saveVendors(List<Vendor> vendors) async {
    // Since storage service only supports single vendor, save the first one
    if (vendors.isNotEmpty) {
      await _storage.saveVendor(vendors.first);
    }
  }
}