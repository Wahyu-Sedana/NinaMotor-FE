import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/enum.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/servismotor/data/models/service_motor_model.dart';

abstract class ServiceDatasource {
  Future<ServisMotorResponse> postService(
      String noKendaraan, String keluhan, JenisMotor jenisMotor);
  Future<ServisMotorResponse> getServiceMotor();
}

class ServiceDatasourceImpl implements ServiceDatasource {
  final Dio dio;

  ServiceDatasourceImpl({required this.dio});

  @override
  Future<ServisMotorResponse> postService(
      String noKendaraan, String keluhan, JenisMotor jenisMotor) async {
    final path = '${baseURL}servis-motor';
    final session = locator<Session>();

    try {
      final response = await dio.post(
        path,
        data: {
          'no_kendaraan': noKendaraan,
          'jenis_motor': jenisMotor.name,
          'keluhan': keluhan
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.getToken}',
          },
        ),
      );
      return ServisMotorResponse.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<ServisMotorResponse> getServiceMotor() async {
    final path = '${baseURL}servis-motor';
    final session = locator<Session>();

    try {
      final response = await dio.get(
        path,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.getToken}',
          },
        ),
      );
      return ServisMotorResponse.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }
}
