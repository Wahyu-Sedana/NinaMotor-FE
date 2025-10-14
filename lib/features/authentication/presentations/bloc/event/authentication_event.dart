import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthenticationEvent {
  final String email;
  final String password;
  final String fcmToken;
  final String phoneId;

  LoginEvent(
      {required this.email,
      required this.password,
      required this.fcmToken,
      required this.phoneId});

  @override
  List<Object?> get props => [email, password];
}

class CheckEmailEvent extends AuthenticationEvent {
  final String email;

  CheckEmailEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

// class ResetPasswordEvent extends AuthenticationEvent {
//   final String email;
//   final String newPassword;

//   ResetPasswordEvent({required this.email, required this.newPassword});

//   @override
//   List<Object?> get props => [email, newPassword];
// }

class RegisterEvent extends AuthenticationEvent {
  final String name;
  final String email;
  final String password;
  final String cPassword;
  // final String alamat;
  final String noTelp;

  RegisterEvent(
      {required this.name,
      required this.email,
      required this.password,
      required this.cPassword,
      required this.noTelp});

  @override
  List<Object?> get props => [name, email, password];
}

class LogoutEvent extends AuthenticationEvent {
  LogoutEvent();

  @override
  List<Object?> get props => [];
}

class ResendVerificationEvent extends AuthenticationEvent {
  final String email;

  ResendVerificationEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordEvent extends AuthenticationEvent {
  final String email;

  ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthenticationEvent {
  final String token;
  final String password;
  final String passwordConfirmation;

  ResetPasswordEvent({
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [token, password, passwordConfirmation];
}

class VerifyEmailEvent extends AuthenticationEvent {
  final String token;

  VerifyEmailEvent({required this.token});

  @override
  List<Object?> get props => [token];
}
