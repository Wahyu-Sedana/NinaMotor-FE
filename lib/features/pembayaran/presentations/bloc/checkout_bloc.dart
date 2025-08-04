import 'package:bloc/bloc.dart';
import 'package:frontend/features/pembayaran/domain/usecases/checkout_usecase.dart';
import 'package:frontend/features/pembayaran/presentations/bloc/event/checkout_event.dart';
import 'package:frontend/features/pembayaran/presentations/bloc/state/checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final TransactionUsecaseImpl transactionUsecaseImpl;

  CheckoutBloc({required this.transactionUsecaseImpl})
      : super(CheckoutInitial()) {
    on<GetCheckoutListEvent>(_onGetCheckout);
  }

  Future<void> _onGetCheckout(
    GetCheckoutListEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());

    final result = await transactionUsecaseImpl.getTransactions(
      userId: event.userId,
      limit: event.limit,
      offset: event.offset,
      status: event.status,
    );

    result.fold(
      (error) => emit(CheckoutError(failure: error)),
      (data) => emit(CheckoutLoaded(data: data)),
    );
  }
}
