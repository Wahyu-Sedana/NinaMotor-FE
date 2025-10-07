import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/home/data/models/review_model.dart';
import 'package:frontend/features/home/data/repositories/review_repository.dart';

abstract class ReviewUsecase {
  Future<Either<Failure, ReviewSummaryModel>> getReviews(String sparepartId);
  Future<Either<Failure, String>> submitReview({
    required String sparepartId,
    required int rating,
    String? komentar,
  });
  Future<Either<Failure, String>> deleteReview(int reviewId);
}

class ReviewUsecaseImpl implements ReviewUsecase {
  final ReviewRepository repository;

  ReviewUsecaseImpl({required this.repository});

  @override
  Future<Either<Failure, ReviewSummaryModel>> getReviews(String sparepartId) {
    return repository.getReviews(sparepartId);
  }

  @override
  Future<Either<Failure, String>> submitReview({
    required String sparepartId,
    required int rating,
    String? komentar,
  }) {
    return repository.submitReview(
      sparepartId: sparepartId,
      rating: rating,
      komentar: komentar,
    );
  }

  @override
  Future<Either<Failure, String>> deleteReview(int reviewId) {
    return repository.deleteReview(reviewId);
  }
}
