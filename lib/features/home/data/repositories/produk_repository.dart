import 'package:dartz/dartz.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/home/data/datasources/produk_datasource.dart';
import 'package:frontend/features/home/data/models/bookmark_model.dart';
import 'package:frontend/features/home/data/models/cart_model.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';

import '../../../../cores/errors/failure.dart';

abstract class SparepartRepository {
  Future<Either<Failure, List<SparepartModel>>> getSparepartList();
  Future<Either<Failure, CartResponse>> addToCart({
    required String sparepartId,
    required int quantity,
  });
  Future<Either<Failure, CartResponse>> getItemCart();
  Future<Either<Failure, CartResponse>> removeCartItem({
    required String sparepartId,
  });
  Future<Either<Failure, BookmarkResponseModel>> addItemBookmark({
    required String sparepartId,
  });
  Future<Either<Failure, BookmarkResponseModel>> getBookmark();
  Future<Either<Failure, List<SparepartModel>>> getSparepartByKategori(
      String namaKategori);
  Future<Either<Failure, BookmarkResponseModel>> removeBookmark({
    required String sparepartId,
  });
}

class SparepartRepositoryImpl implements SparepartRepository {
  final SparepartDatasource sparepartDatasource;

  SparepartRepositoryImpl({required this.sparepartDatasource});

  @override
  Future<Either<Failure, List<SparepartModel>>> getSparepartList() async {
    try {
      final result = await sparepartDatasource.getSparepartList();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartResponse>> addToCart({
    required String sparepartId,
    required int quantity,
  }) async {
    try {
      final result = await sparepartDatasource.addToCart(
        sparepartId: sparepartId,
        quantity: quantity,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartResponse>> getItemCart() async {
    try {
      final result = await sparepartDatasource.getItemCart();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartResponse>> removeCartItem(
      {required String sparepartId}) async {
    try {
      final result =
          await sparepartDatasource.removeItemCart(sparepartId: sparepartId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookmarkResponseModel>> addItemBookmark(
      {required String sparepartId}) async {
    try {
      final result =
          await sparepartDatasource.addBookmark(sparepartId: sparepartId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookmarkResponseModel>> getBookmark() async {
    try {
      final result = await sparepartDatasource.getBookmark();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SparepartModel>>> getSparepartByKategori(
      String namaKategori) async {
    try {
      final result =
          await sparepartDatasource.getSparepartByKategori(namaKategori);
      return Right(result);
    } catch (e) {
      logger(e);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookmarkResponseModel>> removeBookmark(
      {required String sparepartId}) async {
    try {
      final result = await sparepartDatasource.removeBookmarkCart(
          sparepartId: sparepartId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
