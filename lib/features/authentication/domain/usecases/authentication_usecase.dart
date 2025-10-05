import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';
import 'package:frontend/features/authentication/data/repositories/authentication_repository.dart';

abstract class AuthenticationUsecase {
  // Existing methods
  Future<Either<Failure, AuthenticationModel>> callLogin(
      String email, String password, String fcmToken, String phoneId);
  Future<Either<Failure, AuthenticationModelLogout>> callLogout();
  Future<Either<Failure, AuthenticationModel>> callRegister(
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
  Future<Either<Failure, String>> verifyEmail(String token);
  Future<Either<Failure, String>> forgotPassword(String email);
  Future<Either<Failure, String>> resetPasswordWithToken({
    required String token,
    required String password,
    required String passwordConfirmation,
  });
}

class AuthenticationUsecaseImpl implements AuthenticationUsecase {
  final AuthenticationRepository authenticationRepository;

  AuthenticationUsecaseImpl({required this.authenticationRepository});

  @override
  Future<Either<Failure, AuthenticationModel>> callLogin(
      String email, String password, String fcmToken, String phoneId) {
    return authenticationRepository.userLogin(
        email, password, fcmToken, phoneId);
  }

  @override
  Future<Either<Failure, AuthenticationModelLogout>> callLogout() {
    return authenticationRepository.userLogout();
  }

  @override
  Future<Either<Failure, AuthenticationModel>> callRegister(
      String name,
      String email,
      String password,
      String cPassword,
      String alamat,
      String noTelp) async {
    return authenticationRepository.userRegister(
        name, email, password, cPassword, alamat, noTelp);
  }

  @override
  Future<Either<Failure, AuthenticationModel>> checkUserEmaill(String email) {
    return authenticationRepository.checkUserEmaill(email);
  }

  // @override
  // Future<Either<Failure, AuthenticationModel>> resetPassword(
  //     String email, String newPassword) {
  //   return authenticationRepository.resetPassword(email, newPassword);
  // }

  @override
  Future<Either<Failure, String>> resendVerification(String email) {
    return authenticationRepository.resendVerification(email);
  }

  @override
  Future<Either<Failure, String>> verifyEmail(String token) {
    return authenticationRepository.verifyEmail(token);
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) {
    return authenticationRepository.forgotPassword(email);
  }

  @override
  Future<Either<Failure, String>> resetPasswordWithToken({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) {
    return authenticationRepository.resetPassword(
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
