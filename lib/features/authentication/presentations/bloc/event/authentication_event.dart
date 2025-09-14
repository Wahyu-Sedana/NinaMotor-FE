import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthenticationEvent {
  final String email;
  final String password;
  final String fcmToken;

  LoginEvent(
      {required this.email, required this.password, required this.fcmToken});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthenticationEvent {
  final String name;
  final String email;
  final String password;
  final String cPassword;
  final String alamat;
  final String noTelp;

  RegisterEvent(
      {required this.name,
      required this.email,
      required this.password,
      required this.cPassword,
      required this.alamat,
      required this.noTelp});

  @override
  List<Object?> get props => [name, email, password];
}

class LogoutEvent extends AuthenticationEvent {
  LogoutEvent();

  @override
  List<Object?> get props => [];
}
