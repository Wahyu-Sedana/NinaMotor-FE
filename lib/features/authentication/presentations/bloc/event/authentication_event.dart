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

  RegisterEvent(
      {required this.name,
      required this.email,
      required this.password,
      required this.cPassword});

  @override
  List<Object?> get props => [name, email, password];
}

class LogoutEvent extends AuthenticationEvent {
  LogoutEvent();

  @override
  List<Object?> get props => [];
}
