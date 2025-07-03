import 'package:equatable/equatable.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';

abstract class SparepartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SparepartInitial extends SparepartState {}

class SparepartLoading extends SparepartState {}

class SparepartLoaded extends SparepartState {
  final List<SparepartModel> spareparts;

  SparepartLoaded({required this.spareparts});

  @override
  List<Object?> get props => [spareparts];
}

class SparepartError extends SparepartState {
  final Failure failure;

  SparepartError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
