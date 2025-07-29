import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/home/data/models/cart_model.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';
import 'package:frontend/features/home/data/repositories/produk_repository.dart';

abstract class SparepartUsecase {
  Future<Either<Failure, List<SparepartModel>>> getAllSpareparts();
  Future<Either<Failure, CartResponse>> addToCart({
    required String sparepartId,
    required int quantity,
  });
  Future<Either<Failure, CartResponse>> getItemCart();
  Future<Either<Failure, CartResponse>> removeItemCart(
      {required String sparepartId});
}

class SparepartUsecaseImpl implements SparepartUsecase {
  final SparepartRepository repository;

  SparepartUsecaseImpl({required this.repository});

  @override
  Future<Either<Failure, List<SparepartModel>>> getAllSpareparts() {
    return repository.getSparepartList();
  }

  @override
  Future<Either<Failure, CartResponse>> addToCart({
    required String sparepartId,
    required int quantity,
  }) {
    return repository.addToCart(
      sparepartId: sparepartId,
      quantity: quantity,
    );
  }

  @override
  Future<Either<Failure, CartResponse>> getItemCart() async {
    return repository.getItemCart();
  }

  @override
  Future<Either<Failure, CartResponse>> removeItemCart(
      {required String sparepartId}) async {
    return repository.removeCartItem(sparepartId: sparepartId);
  }
}
