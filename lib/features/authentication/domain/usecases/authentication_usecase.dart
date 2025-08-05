import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';
import 'package:frontend/features/authentication/data/repositories/authentication_repository.dart';

abstract class AuthenticationUsecase {
  Future<Either<Failure, AuthenticationModel>> callLogin(
      String email, String password, String fcmToken);
  Future<Either<Failure, AuthenticationModelLogout>> callLogout();
  Future<Either<Failure, AuthenticationModel>> callRegister(
      String name, String email, String password, String cPassword);
}

class AuthenticationUsecaseImpl implements AuthenticationUsecase {
  final AuthenticationRepository authenticationRepository;

  AuthenticationUsecaseImpl({required this.authenticationRepository});

  @override
  Future<Either<Failure, AuthenticationModel>> callLogin(
      String email, String password, String fcmToken) {
    return authenticationRepository.userLogin(email, password, fcmToken);
  }

  @override
  Future<Either<Failure, AuthenticationModelLogout>> callLogout() {
    return authenticationRepository.userLogout();
  }

  @override
  Future<Either<Failure, AuthenticationModel>> callRegister(
      String name, String email, String password, String cPassword) async {
    return authenticationRepository.userRegister(
        name, email, password, cPassword);
  }
}
