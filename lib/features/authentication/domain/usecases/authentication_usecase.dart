import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';
import 'package:frontend/features/authentication/data/repositories/authentication_repository.dart';

abstract class AuthenticationUsecase {
  Future<Either<Failure, AuthenticationModelLogin>> callLogin(
      String email, String password);
  Future<Either<Failure, AuthenticationModelLogout>> callLogout();
}

class AuthenticationUsecaseImpl implements AuthenticationUsecase {
  final AuthenticationRepository authenticationRepository;

  AuthenticationUsecaseImpl({required this.authenticationRepository});

  @override
  Future<Either<Failure, AuthenticationModelLogin>> callLogin(
      String email, String password) {
    return authenticationRepository.userLogin(email, password);
  }

  @override
  Future<Either<Failure, AuthenticationModelLogout>> callLogout() {
    return authenticationRepository.userLogout();
  }
}
