class ReviewSummaryModel {
  final String sparepart;
  final double averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  ReviewSummaryModel({
    required this.sparepart,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReviewSummaryModel(
      sparepart: json['sparepart'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      reviews: (json['reviews'] as List)
          .map((e) => ReviewModel.fromJson(e))
          .toList(),
    );
  }
}

class ReviewModel {
  final int id;
  final String sparepartId;
  final String userId;
  final int rating;
  final String komentar;
  final DateTime createdAt;
  final String? userNama;
  final String? profile;

  ReviewModel(
      {required this.id,
      required this.sparepartId,
      required this.userId,
      required this.rating,
      required this.komentar,
      required this.createdAt,
      this.userNama,
      this.profile});

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
        id: json['id'],
        sparepartId: json['sparepart_id'],
        userId: json['user_id'],
        rating: json['rating'],
        komentar: json['komentar'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
        userNama: json['user']?['nama'],
        profile: json['user']?['profile']);
  }
}
