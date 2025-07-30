import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/servismotor/data/models/service_motor_model.dart';
import 'package:frontend/cores/utils/enum.dart';
import 'package:frontend/features/servismotor/data/repositories/service_motor_repository.dart';

abstract class ServisMotorUsecase {
  Future<Either<Failure, ServisMotorResponse>> callPostServisMotor({
    required String noKendaraan,
    required String keluhan,
    required JenisMotor jenisMotor,
  });
  Future<Either<Failure, ServisMotorResponse>> callGetServisMotor();
}

class ServisMotorUsecaseImpl implements ServisMotorUsecase {
  final ServiceRepository repository;
  ServisMotorUsecaseImpl({required this.repository});

  @override
  Future<Either<Failure, ServisMotorResponse>> callPostServisMotor({
    required String noKendaraan,
    required String keluhan,
    required JenisMotor jenisMotor,
  }) {
    return repository.postService(
      noKendaraan,
      keluhan,
      jenisMotor,
    );
  }

  @override
  Future<Either<Failure, ServisMotorResponse>> callGetServisMotor() async {
    return repository.getService();
  }
}
