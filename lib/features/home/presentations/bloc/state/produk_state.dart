import 'package:equatable/equatable.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/home/data/models/bookmark_model.dart';
import 'package:frontend/features/home/data/models/cart_model.dart';
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

class KategoriSparepartLoaded extends SparepartState {
  final SparepartResponse sparepartsByKategori;

  KategoriSparepartLoaded({required this.sparepartsByKategori});

  @override
  List<Object?> get props => [sparepartsByKategori];
}

class SparepartError extends SparepartState {
  final Failure failure;

  SparepartError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class CartLoading extends SparepartState {}

class CartSuccess extends SparepartState {
  final CartResponse data;

  CartSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class CartFailure extends SparepartState {
  final Failure failure;

  CartFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class BookmarkLoading extends SparepartState {}

class BookmarkSuccess extends SparepartState {
  final List<BookmarkModel> data;

  BookmarkSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class GetBookmarkListSuccess extends SparepartState {
  final List<BookmarkModel> bookmarks;
  GetBookmarkListSuccess({required this.bookmarks});
}

class BookmarkFailure extends SparepartState {
  final Failure failure;

  BookmarkFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}
