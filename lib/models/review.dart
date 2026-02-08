import 'enums.dart';

class Review {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String targetId;
  final String? orderId;
  final String? transactionId;
  final ReviewType type;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.targetId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.orderId,
    this.transactionId,
    this.type = ReviewType.vendor,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'reviewerId': reviewerId,
    'reviewerName': reviewerName,
    'targetId': targetId,
    'orderId': orderId,
    'transactionId': transactionId,
    'type': type.name,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    reviewerId: json['reviewerId'],
    reviewerName: json['reviewerName'],
    targetId: json['targetId'],
    orderId: json['orderId'],
    transactionId: json['transactionId'],
    type: json['type'] != null ? ReviewType.values.byName(json['type']) : ReviewType.vendor,
    rating: json['rating'].toDouble(),
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
