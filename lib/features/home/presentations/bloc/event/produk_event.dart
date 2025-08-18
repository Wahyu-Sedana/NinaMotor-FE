import 'package:equatable/equatable.dart';

abstract class SparepartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetAllSparepartsEvent extends SparepartEvent {}

class AddToCartEvent extends SparepartEvent {
  final String sparepartId;
  final int quantity;

  AddToCartEvent({required this.sparepartId, required this.quantity});

  @override
  List<Object?> get props => [sparepartId, quantity];
}

class RemoveFromCartEvent extends SparepartEvent {
  final String sparepartId;
  RemoveFromCartEvent({
    required this.sparepartId,
  });
  @override
  List<Object?> get props => [sparepartId];
}

class RemoveFromBookmarkEvent extends SparepartEvent {
  final String sparepartId;
  RemoveFromBookmarkEvent({
    required this.sparepartId,
  });
  @override
  List<Object?> get props => [sparepartId];
}

class AddToItemBookmarkEvent extends SparepartEvent {
  final String sparepartId;
  AddToItemBookmarkEvent({
    required this.sparepartId,
  });
  @override
  List<Object?> get props => [sparepartId];
}

class GetSparepartByKategoriEvent extends SparepartEvent {
  final String namaKategori;
  GetSparepartByKategoriEvent({
    required this.namaKategori,
  });
  @override
  List<Object?> get props => [namaKategori];
}

class GetItemCartEvent extends SparepartEvent {}

class GetItemBookmarkEvent extends SparepartEvent {}
