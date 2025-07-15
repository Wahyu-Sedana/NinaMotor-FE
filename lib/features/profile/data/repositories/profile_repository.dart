import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/profile/data/datasources/profile_datasource.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getProfile();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource datasource;
  ProfileRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, ProfileModel>> getProfile() async {
    try {
      final getProfile = await datasource.getProfile();
      return Right(getProfile);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
