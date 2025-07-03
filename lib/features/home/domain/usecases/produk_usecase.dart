import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';
import 'package:frontend/features/home/data/repositories/produk_repository.dart';

abstract class SparepartUsecase {
  Future<Either<Failure, List<SparepartModel>>> getAllSpareparts();
}

class SparepartUsecaseImpl implements SparepartUsecase {
  final SparepartRepository repository;

  SparepartUsecaseImpl({required this.repository});

  @override
  Future<Either<Failure, List<SparepartModel>>> getAllSpareparts() {
    return repository.getSparepartList();
  }
}
