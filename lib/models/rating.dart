class RatingReview {
  final String id;
  final int rating;
  final String? review;
  final String customerName;
  final String createdAt;

  const RatingReview({
    required this.id,
    required this.rating,
    this.review,
    required this.customerName,
    required this.createdAt,
  });

  factory RatingReview.fromJson(Map<String, dynamic> json) => RatingReview(
    id: '${json['id'] ?? ''}',
    rating: int.tryParse('${json['rating']}') ?? 0,
    review: json['review']?.toString(),
    customerName: '${json['customer_name'] ?? 'Customer'}',
    createdAt: '${json['created_at'] ?? ''}',
  );
}
