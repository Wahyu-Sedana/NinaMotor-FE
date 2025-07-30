import 'package:dartz/dartz.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/servismotor/data/datasources/service_motor_datasource.dart';
import 'package:frontend/features/servismotor/data/models/service_motor_model.dart';
import 'package:frontend/cores/utils/enum.dart';

abstract class ServiceRepository {
  Future<Either<Failure, ServisMotorResponse>> postService(
    String noKendaraan,
    String keluhan,
    JenisMotor jenisMotor,
  );
  Future<Either<Failure, ServisMotorResponse>> getService();
}

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceDatasource datasource;

  ServiceRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, ServisMotorResponse>> postService(
    String noKendaraan,
    String keluhan,
    JenisMotor jenisMotor,
  ) async {
    try {
      final result =
          await datasource.postService(noKendaraan, keluhan, jenisMotor);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServisMotorResponse>> getService() async {
    try {
      final result = await datasource.getServiceMotor();
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
