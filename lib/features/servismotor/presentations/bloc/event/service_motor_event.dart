import 'package:equatable/equatable.dart';
import 'package:frontend/cores/utils/enum.dart';

abstract class MotorServiceEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetMotorServiceEvent extends MotorServiceEvent {}

class SubmitMotorServiceEvent extends MotorServiceEvent {
  final String noKendaraan;
  final String keluhan;
  final JenisMotor jenisMotor;

  SubmitMotorServiceEvent({
    required this.noKendaraan,
    required this.keluhan,
    required this.jenisMotor,
  });

  @override
  List<Object> get props => [noKendaraan, keluhan, jenisMotor];
}
