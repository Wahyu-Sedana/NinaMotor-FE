import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/pembayaran/data/datasources/checkout_datasource.dart';
import 'package:frontend/features/pembayaran/data/models/checkout_model.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    required int limit,
    required int offset,
    String? status,
  });
}

class TransactionRepositoryImpl implements TransactionRepository {
  final CheckoutDatasource datasource;

  TransactionRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    required int limit,
    required int offset,
    String? status,
  }) async {
    try {
      final result = await datasource.getTransactions(
        userId: userId,
        limit: limit,
        offset: offset,
        status: status,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
