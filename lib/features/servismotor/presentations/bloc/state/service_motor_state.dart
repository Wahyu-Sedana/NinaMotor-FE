import 'package:equatable/equatable.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/servismotor/data/models/service_motor_model.dart';

abstract class MotorServiceState extends Equatable {
  @override
  List<Object> get props => [];
}

class MotorServiceInitial extends MotorServiceState {}

class MotorServiceLoading extends MotorServiceState {}

class MotorServiceLoadSuccess extends MotorServiceState {
  final ServisMotorResponse data;

  MotorServiceLoadSuccess({required this.data});

  @override
  List<Object> get props => [data];
}

class MotorServiceSubmitSuccess extends MotorServiceState {
  final String message;

  MotorServiceSubmitSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class MotorServiceDetailLoaded extends MotorServiceState {
  final ServisMotorModel detail;

  MotorServiceDetailLoaded({required this.detail});

  @override
  List<Object> get props => [detail];
}

class MotorServiceError extends MotorServiceState {
  final Failure failure;

  MotorServiceError({required this.failure});

  @override
  List<Object> get props => [failure];
}
