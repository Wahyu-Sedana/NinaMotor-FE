import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';
import 'package:frontend/features/profile/data/repositories/profile_repository.dart';

abstract class ProfileUsecase {
  Future<Either<Failure, ProfileModel>> callProfile();
}

class ProfileUsecaseImpl implements ProfileUsecase {
  final ProfileRepository repository;
  ProfileUsecaseImpl({required this.repository});

  @override
  Future<Either<Failure, ProfileModel>> callProfile() async {
    return repository.getProfile();
  }
}
