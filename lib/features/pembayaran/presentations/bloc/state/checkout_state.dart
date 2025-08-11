import 'package:equatable/equatable.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/pembayaran/data/models/checkout_model.dart';

abstract class CheckoutState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutLoaded extends CheckoutState {
  final List<Transaction> data;

  CheckoutLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class CheckoutError extends CheckoutState {
  final Failure failure;

  CheckoutError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
