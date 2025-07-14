import 'package:equatable/equatable.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationLoginLoading extends AuthenticationState {}

class AuthenticationLoginInitial extends AuthenticationState {}

class AuthenticationLoginSuccess extends AuthenticationState {
  final AuthenticationModelLogin authenticationModelLogin;
  AuthenticationLoginSuccess({
    required this.authenticationModelLogin,
  });
  @override
  List<Object> get props => [AuthenticationModelLogin];
}

class AuthenticationLoginError extends AuthenticationState {
  final Failure failure;
  AuthenticationLoginError({
    required this.failure,
  });
  @override
  List<Object> get props => [failure];
}

class AuthenticationLogoutLoading extends AuthenticationState {}

class AuthenticationLogoutInitial extends AuthenticationState {}

class AuthenticationLogoutSuccess extends AuthenticationState {
  AuthenticationLogoutSuccess();
  @override
  List<Object> get props => [AuthenticationLogoutSuccess];
}

class AuthenticationLogoutError extends AuthenticationState {
  final Failure failure;
  AuthenticationLogoutError({
    required this.failure,
  });
  @override
  List<Object> get props => [failure];
}

// class AuthenticationRegisterLoading extends AuthenticationState {}

// class AuthenticationRegisterInitial extends AuthenticationState {}

// class AuthenticationRegisterSuccess extends AuthenticationState {
//   final AuthenticationModelRegister authenticationModelRegister;
//   AuthenticationRegisterSuccess({
//     required this.authenticationModelRegister,
//   });
//   @override
//   List<Object> get props => [AuthenticationModelLogin];
// }

// class AuthenticationRegisterError extends AuthenticationState {
//   final Failure failure;
//   AuthenticationRegisterError({
//     required this.failure,
//   });
//   @override
//   List<Object> get props => [failure];
// }
