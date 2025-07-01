import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final int? code;
  final String message;
  final int? status;

  const Failure({this.message = '', this.code, this.status});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.code, String? message, super.status})
      : super(message: message ?? "");
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({String? message}) : super(message: message ?? "");
}

class CacheFailure extends Failure {}
