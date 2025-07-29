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

class GetItemCartEvent extends SparepartEvent {}
