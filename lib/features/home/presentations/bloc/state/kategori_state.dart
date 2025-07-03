import 'package:equatable/equatable.dart';
import 'package:frontend/features/home/data/models/kategori_model.dart';
import 'package:frontend/cores/errors/failure.dart';

abstract class KategoriState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KategoriInitial extends KategoriState {}

class KategoriLoading extends KategoriState {}

class KategoriLoaded extends KategoriState {
  final List<KategoriModel> kategoriList;

  KategoriLoaded({required this.kategoriList});

  @override
  List<Object?> get props => [kategoriList];
}

class KategoriError extends KategoriState {
  final Failure failure;

  KategoriError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
