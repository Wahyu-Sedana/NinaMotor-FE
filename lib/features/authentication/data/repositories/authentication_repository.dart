import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/authentication/data/datasources/authentication_datasource.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, AuthenticationModel>> userLogin(
      String email, String password, String fcmToken, String phoneId);
  Future<Either<Failure, AuthenticationModelLogout>> userLogout();
  Future<Either<Failure, AuthenticationModel>> userRegister(
      String name,
      String email,
      String password,
      String cPassword,
      String alamat,
      String noTelp);
  Future<Either<Failure, AuthenticationModel>> checkUserEmaill(String email);
  // Future<Either<Failure, AuthenticationModel>> resetPassword(
  //     String email, String newPassword);

  Future<Either<Failure, String>> resendVerification(String email);

  Future<Either<Failure, String>> forgotPassword(String email);

  Future<Either<Failure, String>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, String>> verifyEmail(String token);
}

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationDatasource authenticationDatasource;

  AuthenticationRepositoryImpl({required this.authenticationDatasource});

  @override
  Future<Either<Failure, AuthenticationModel>> userLogin(
      String email, String password, String fcmToken, String phoneId) async {
    try {
      final authenticationModelLogin = await authenticationDatasource.userLogin(
          email, password, fcmToken, phoneId);
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
      String name,
      String email,
      String password,
      String cPassword,
      String alamat,
      String noTelp) async {
    try {
      final authenticationModelRegister = await authenticationDatasource
          .userRegister(name, email, password, cPassword, alamat, noTelp);
      return Right(authenticationModelRegister);
    } on Exception catch (e) {
      return Left(ServerFailure(code: 500, message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthenticationModel>> checkUserEmaill(
      String email) async {
    try {
      final authenticationModelEmail =
          await authenticationDatasource.checkUserEmaill(email);
      if (authenticationModelEmail.status == 404) {
        return Left(ServerFailure(
            code: 404, message: authenticationModelEmail.message));
      } else {
        return Right(authenticationModelEmail);
      }
    } on Exception catch (e) {
      return Left(ServerFailure(code: 500, message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resendVerification(String email) async {
    try {
      final result = await authenticationDatasource.resendVerification(email);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    try {
      final result = await authenticationDatasource.forgotPassword(email);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final result = await authenticationDatasource.resetPassword(
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyEmail(String token) async {
    try {
      final result = await authenticationDatasource.verifyEmail(token);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
