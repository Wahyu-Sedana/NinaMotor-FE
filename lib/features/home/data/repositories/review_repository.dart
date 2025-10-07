import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/home/data/datasources/review_datasource.dart';
import 'package:frontend/features/home/data/models/review_model.dart';

abstract class ReviewRepository {
  Future<Either<Failure, ReviewSummaryModel>> getReviews(String sparepartId);

  Future<Either<Failure, String>> submitReview({
    required String sparepartId,
    required int rating,
    String? komentar,
  });

  Future<Either<Failure, String>> deleteReview(int reviewId);
}

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDatasource remoteDatasource;

  ReviewRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, ReviewSummaryModel>> getReviews(
      String sparepartId) async {
    try {
      final result = await remoteDatasource.getReviews(sparepartId);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> submitReview({
    required String sparepartId,
    required int rating,
    String? komentar,
  }) async {
    try {
      final result = await remoteDatasource.submitReview(
        sparepartId: sparepartId,
        rating: rating,
        komentar: komentar,
      );
      return Right(result['message'] ?? 'Review berhasil dikirim');
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteReview(int reviewId) async {
    try {
      final result = await remoteDatasource.deleteReview(reviewId);
      return Right(result['message'] ?? 'Review berhasil dihapus');
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
