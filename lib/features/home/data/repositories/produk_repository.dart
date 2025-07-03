import 'package:dartz/dartz.dart';
import 'package:frontend/features/home/data/datasources/produk_datasource.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';

import '../../../../cores/errors/failure.dart';

abstract class SparepartRepository {
  Future<Either<Failure, List<SparepartModel>>> getSparepartList();
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
}
