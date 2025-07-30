import 'package:bloc/bloc.dart';
import 'package:frontend/features/servismotor/domain/usecases/service_motor_usecase.dart';
import 'package:frontend/features/servismotor/presentations/bloc/event/service_motor_event.dart';
import 'package:frontend/features/servismotor/presentations/bloc/state/service_motor_state.dart';

class MotorServiceBloc extends Bloc<MotorServiceEvent, MotorServiceState> {
  final ServisMotorUsecaseImpl usecase;

  MotorServiceBloc({required this.usecase}) : super(MotorServiceInitial()) {
    on<SubmitMotorServiceEvent>(_onPostService);
    on<GetMotorServiceEvent>(_onGetServiceList);
  }

  Future<void> _onPostService(
      SubmitMotorServiceEvent event, Emitter<MotorServiceState> emit) async {
    emit(MotorServiceLoading());

    final result = await usecase.callPostServisMotor(
      noKendaraan: event.noKendaraan,
      keluhan: event.keluhan,
      jenisMotor: event.jenisMotor,
    );

    result.fold(
      (failure) => emit(MotorServiceError(failure: failure)),
      (data) => emit(MotorServiceSubmitSuccess(
          message: data.message ?? 'Berhasil diajukan')),
    );
  }

  Future<void> _onGetServiceList(
      GetMotorServiceEvent event, Emitter<MotorServiceState> emit) async {
    emit(MotorServiceLoading());

    final result = await usecase.callGetServisMotor();

    result.fold(
      (failure) => emit(MotorServiceError(failure: failure)),
      (data) => emit(MotorServiceLoadSuccess(data: data)),
    );
  }
}
