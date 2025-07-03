import 'package:equatable/equatable.dart';

abstract class SparepartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetAllSparepartsEvent extends SparepartEvent {}
