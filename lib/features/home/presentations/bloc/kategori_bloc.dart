import 'package:bloc/bloc.dart';
import 'package:frontend/features/home/domain/usecases/kategori_usecase.dart';
import 'package:frontend/features/home/presentations/bloc/event/kategori_event.dart';
import 'package:frontend/features/home/presentations/bloc/state/kategori_state.dart';

class KategoriBloc extends Bloc<KategoriEvent, KategoriState> {
  final KategoriUsecaseImpl kategoriUsecaseImpl;

  KategoriBloc({required this.kategoriUsecaseImpl}) : super(KategoriInitial()) {
    on<GetAllKategoriEvent>(_onGetAllKategori);
  }

  Future<void> _onGetAllKategori(
      GetAllKategoriEvent event, Emitter<KategoriState> emit) async {
    emit(KategoriLoading());

    final result = await kategoriUsecaseImpl.getAllKategori();

    result.fold(
      (error) => emit(KategoriError(failure: error)),
      (data) => emit(KategoriLoaded(kategoriList: data)),
    );
  }
}
