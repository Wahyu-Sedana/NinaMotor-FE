import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthenticationEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// class RegisterEvent extends AuthenticationEvent {
//   final String email;
//   final String username;
//   final String password;

//   RegisterEvent(
//       {required this.email, required this.username, required this.password});

//   @override
//   List<Object?> get props => [email, username, password];
// }
