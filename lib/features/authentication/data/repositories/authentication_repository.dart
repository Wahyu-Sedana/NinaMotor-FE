import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/authentication/data/datasources/authentication_datasource.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, AuthenticationModel>> userLogin(
      String email, String password);
  Future<Either<Failure, AuthenticationModelLogout>> userLogout();
  Future<Either<Failure, AuthenticationModel>> userRegister(
      String name, String email, String password, String cPassword);
}

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationDatasource authenticationDatasource;

  AuthenticationRepositoryImpl({required this.authenticationDatasource});

  @override
  Future<Either<Failure, AuthenticationModel>> userLogin(
      String email, String password) async {
    try {
      final authenticationModelLogin =
          await authenticationDatasource.userLogin(email, password);
      if (authenticationModelLogin.status == 404) {
        return Left(ServerFailure(
            code: 404, message: authenticationModelLogin.message));
      } else {
        return Right(authenticationModelLogin);
      }
    } on Exception catch (e) {
      return Left(ServerFailure(code: 500, message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthenticationModelLogout>> userLogout() async {
    try {
      final authenticationModelLogout =
          await authenticationDatasource.userLogout();
      return Right(authenticationModelLogout);
    } on Exception catch (e) {
      return Left(ServerFailure(code: 500, message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthenticationModel>> userRegister(
      String name, String email, String password, String cPassword) async {
    try {
      final authenticationModelRegister = await authenticationDatasource
          .userRegister(name, email, password, cPassword);
      return Right(authenticationModelRegister);
    } on Exception catch (e) {
      return Left(ServerFailure(code: 500, message: e.toString()));
    }
  }
}
