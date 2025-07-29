import 'package:bloc/bloc.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/home/domain/usecases/produk_usecase.dart';
import 'package:frontend/features/home/presentations/bloc/event/produk_event.dart';
import 'package:frontend/features/home/presentations/bloc/state/produk_state.dart';

class SparepartBloc extends Bloc<SparepartEvent, SparepartState> {
  final SparepartUsecaseImpl sparepartUsecaseImpl;

  SparepartBloc({required this.sparepartUsecaseImpl})
      : super(SparepartInitial()) {
    on<GetAllSparepartsEvent>(_onGetAllSpareparts);
    on<AddToCartEvent>(_onAddToCart);
    on<GetItemCartEvent>(_onGetItemCart);
    on<RemoveFromCartEvent>(_onRemoveItemCart);
  }

  Future<void> _onGetAllSpareparts(
      GetAllSparepartsEvent event, Emitter<SparepartState> emit) async {
    emit(SparepartLoading());

    final result = await sparepartUsecaseImpl.getAllSpareparts();

    result.fold(
      (error) => emit(SparepartError(failure: error)),
      (data) => emit(SparepartLoaded(spareparts: data)),
    );
  }

  Future<void> _onAddToCart(
      AddToCartEvent event, Emitter<SparepartState> emit) async {
    emit(CartLoading());

    final result = await sparepartUsecaseImpl.addToCart(
      sparepartId: event.sparepartId,
      quantity: event.quantity,
    );

    logger(result);

    result.fold(
      (failure) {
        logger(failure);
        emit(CartFailure(failure: failure));
      },
      (data) => emit(CartSuccess(data: data)),
    );
  }

  Future<void> _onGetItemCart(
      GetItemCartEvent event, Emitter<SparepartState> emit) async {
    emit(CartLoading());

    final result = await sparepartUsecaseImpl.getItemCart();

    logger(result);

    result.fold(
      (failure) {
        logger(failure);
        emit(CartFailure(failure: failure));
      },
      (data) => emit(CartSuccess(data: data)),
    );
  }

  Future<void> _onRemoveItemCart(
      RemoveFromCartEvent event, Emitter<SparepartState> emit) async {
    emit(CartLoading());
    final result = await sparepartUsecaseImpl.removeItemCart(
        sparepartId: event.sparepartId);
    result.fold(
      (failure) async {
        logger(failure);
        emit(CartFailure(failure: failure));
      },
      (data) async {
        emit(CartSuccess(data: data));
        await Future.delayed(Duration(milliseconds: 300));
        add(GetItemCartEvent());
      },
    );
  }
}
