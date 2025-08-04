import 'package:equatable/equatable.dart';

abstract class CheckoutEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetCheckoutListEvent extends CheckoutEvent {
  final String userId;
  final int limit;
  final int offset;
  final String? status;

  GetCheckoutListEvent({
    required this.userId,
    required this.limit,
    required this.offset,
    this.status,
  });

  @override
  List<Object?> get props => [userId, limit, offset, status];
}
