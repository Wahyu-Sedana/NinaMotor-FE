import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/authentication/data/datasources/authentication_datasource.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, AuthenticationModelLogin>> userLogin(
      String email, String password);
}

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationDatasource authenticationDatasource;

  AuthenticationRepositoryImpl({required this.authenticationDatasource});

  @override
  Future<Either<Failure, AuthenticationModelLogin>> userLogin(
      String email, String password) async {
    try {
      final authenticationModelLogin =
          await authenticationDatasource.userLogin(email, password);
      return Right(authenticationModelLogin);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
