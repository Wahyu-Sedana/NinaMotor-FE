import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/pembayaran/data/models/checout_model.dart';
import 'package:frontend/features/pembayaran/data/repositories/checkout_repository.dart';

abstract class TransactionUsecase {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    required int limit,
    required int offset,
    String? status,
  });
}

class TransactionUsecaseImpl implements TransactionUsecase {
  final TransactionRepository repository;

  TransactionUsecaseImpl({
    required this.repository,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions(
      {required String userId,
      required int limit,
      required int offset,
      String? status}) async {
    return await repository.getTransactions(
      userId: userId,
      limit: limit,
      offset: offset,
      status: status,
    );
  }
}
