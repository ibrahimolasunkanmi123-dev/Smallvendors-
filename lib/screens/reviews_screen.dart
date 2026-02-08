import 'package:flutter/material.dart';
import '../models/review.dart';
import '../models/vendor.dart';
import '../models/enums.dart';
import '../services/review_service.dart';

class ReviewsScreen extends StatefulWidget {
  final Vendor vendor;
  
  const ReviewsScreen({super.key, required this.vendor});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _reviewService = ReviewService();
  List<Review> _reviews = [];
  bool _loading = true;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() async {
    final reviews = await _reviewService.getReviewsForTarget(widget.vendor.id, ReviewType.vendor);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _averageRating = _calculateAverageRating();
        _loading = false;
      });
    }
  }

  double _calculateAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    final sum = _reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return sum / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildRatingSummary(),
                Expanded(child: _buildReviewsList()),
              ],
            ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              _buildStarRating(_averageRating),
              Text('${_reviews.length} reviews'),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(child: _buildRatingBreakdown()),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildRatingBreakdown() {
    final ratingCounts = <int, int>{};
    for (final review in _reviews) {
      ratingCounts[review.rating.round()] = (ratingCounts[review.rating.round()] ?? 0) + 1;
    }

    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final count = ratingCounts[stars] ?? 0;
        final percentage = _reviews.isEmpty ? 0.0 : count / _reviews.length;
        
        return Row(
          children: [
            Text('$stars'),
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              ),
            ),
            const SizedBox(width: 8),
            Text('$count'),
          ],
        );
      }),
    );
  }

  Widget _buildReviewsList() {
    if (_reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No reviews yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(review.reviewerName[0].toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.reviewerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _buildStarRating(review.rating),
                        ],
                      ),
                    ),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                if (review.comment.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(review.comment),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}