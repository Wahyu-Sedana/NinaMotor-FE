import 'package:dio/dio.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/home/data/models/review_model.dart';

abstract class ReviewRemoteDatasource {
  Future<ReviewSummaryModel> getReviews(String sparepartId);
  Future<Map<String, dynamic>> submitReview({
    required String sparepartId,
    required int rating,
    String? komentar,
  });
  Future<Map<String, dynamic>> deleteReview(int reviewId);
}

class ReviewRemoteDatasourceImpl implements ReviewRemoteDatasource {
  final Dio dio;

  ReviewRemoteDatasourceImpl({required this.dio});

  @override
  Future<ReviewSummaryModel> getReviews(String sparepartId) async {
    final String url = '${AppConfig.baseURL}reviews/$sparepartId';
    final session = locator<Session>();

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          },
        ),
      );

      return ReviewSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Get Reviews Error");
      throw ServerFailure(
        message: e.response?.data['message'] ?? 'Gagal memuat ulasan',
        status: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> submitReview({
    required String sparepartId,
    required int rating,
    String? komentar,
  }) async {
    final String url = '${AppConfig.baseURL}reviews';
    final session = locator<Session>();

    try {
      final response = await dio.post(
        url,
        data: {
          'sparepart_id': sparepartId,
          'rating': rating,
          if (komentar != null && komentar.isNotEmpty) 'komentar': komentar,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Submit Review Error");
      throw ServerFailure(
        message: e.response?.data['message'] ?? 'Gagal mengirim ulasan',
        status: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    final String url = '${AppConfig.baseURL}reviews/$reviewId';
    final session = locator<Session>();

    try {
      final response = await dio.delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Delete Review Error");
      throw ServerFailure(
        message: e.response?.data['message'] ?? 'Gagal menghapus ulasan',
        status: e.response?.statusCode,
      );
    }
  }
}
