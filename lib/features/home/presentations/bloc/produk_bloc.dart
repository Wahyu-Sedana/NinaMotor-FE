import 'package:bloc/bloc.dart';
import 'package:frontend/features/home/domain/usecases/produk_usecase.dart';
import 'package:frontend/features/home/presentations/bloc/event/produk_event.dart';
import 'package:frontend/features/home/presentations/bloc/state/produk_state.dart';

class SparepartBloc extends Bloc<SparepartEvent, SparepartState> {
  final SparepartUsecaseImpl sparepartUsecaseImpl;

  SparepartBloc({required this.sparepartUsecaseImpl})
      : super(SparepartInitial()) {
    on<GetAllSparepartsEvent>(_onGetAllSpareparts);
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
}
