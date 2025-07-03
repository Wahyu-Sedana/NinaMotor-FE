import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/home/data/datasources/kategori_produk_datasource.dart';
import 'package:frontend/features/home/data/models/kategori_model.dart';

abstract class KategoriRepository {
  Future<Either<Failure, List<KategoriModel>>> getKategoriList();
}

class KategoriRepositoryImpl implements KategoriRepository {
  final KategoriDatasource kategoriDatasource;

  KategoriRepositoryImpl({required this.kategoriDatasource});

  @override
  Future<Either<Failure, List<KategoriModel>>> getKategoriList() async {
    try {
      final result = await kategoriDatasource.getKategoriList();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
