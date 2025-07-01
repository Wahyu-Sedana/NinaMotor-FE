import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';

abstract class AuthenticationDatasource {
  Future<AuthenticationModelLogin> userLogin(String email, String password);
}

class AuthenticationLoginDataSource implements AuthenticationDatasource {
  final Dio dio;
  AuthenticationLoginDataSource({required this.dio});

  @override
  Future<AuthenticationModelLogin> userLogin(
      String email, String password) async {
    final String url = '${baseURL}login';
    try {
      final response =
          await dio.post(url, data: {'email': email, 'password': password});

      return AuthenticationModelLogin.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.toString(), label: "error login datasource");
      throw (e.toString());
    }
  }
}
