enum PaymentMethod {
  cash,
  card,
  mobile,
}

enum TransactionStatus {
  pending,
  completed,
  cancelled,
  refunded,
}

enum ReviewType {
  vendor,
  product,
  order,
}

class RatingStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  RatingStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  Map<String, dynamic> toJson() => {
    'averageRating': averageRating,
    'totalReviews': totalReviews,
    'ratingDistribution': ratingDistribution,
  };

  factory RatingStats.fromJson(Map<String, dynamic> json) => RatingStats(
    averageRating: json['averageRating'].toDouble(),
    totalReviews: json['totalReviews'],
    ratingDistribution: Map<int, int>.from(json['ratingDistribution']),
  );

  factory RatingStats.fromReviews(List reviews) {
    if (reviews.isEmpty) {
      return RatingStats(
        averageRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {},
      );
    }

    final Map<int, int> distribution = {};
    double totalRating = 0.0;

    for (final review in reviews) {
      final rating = review.rating as int;
      totalRating += rating;
      distribution[rating] = (distribution[rating] ?? 0) + 1;
    }

    return RatingStats(
      averageRating: totalRating / reviews.length,
      totalReviews: reviews.length,
      ratingDistribution: distribution,
    );
  }
}