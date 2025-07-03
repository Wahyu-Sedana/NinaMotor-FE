import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/home/data/models/kategori_model.dart';
import 'package:frontend/features/home/data/repositories/kategori_repository.dart';

abstract class KategoriUsecase {
  Future<Either<Failure, List<KategoriModel>>> getAllKategori();
}

class KategoriUsecaseImpl implements KategoriUsecase {
  final KategoriRepository repository;

  KategoriUsecaseImpl({required this.repository});

  @override
  Future<Either<Failure, List<KategoriModel>>> getAllKategori() {
    return repository.getKategoriList();
  }
}
