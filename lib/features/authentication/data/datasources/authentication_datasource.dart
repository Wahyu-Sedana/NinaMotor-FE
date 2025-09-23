import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';

abstract class AuthenticationDatasource {
  Future<AuthenticationModel> userLogin(
      String email, String password, String fcmToken);
  Future<AuthenticationModelLogout> userLogout();
  Future<AuthenticationModel> userRegister(String name, String email,
      String password, String cPassword, String alamat, String noTelp);
  Future<AuthenticationModel> checkUserEmaill(String email);
  Future<AuthenticationModel> resetPassword(String email, String newPassword);
}

class AuthenticationDataSourceImpl implements AuthenticationDatasource {
  final Dio dio;
  AuthenticationDataSourceImpl({required this.dio});

  @override
  Future<AuthenticationModel> userLogin(
      String email, String password, String fcmToken) async {
    final String url = '${AppConfig.baseURL}login';
    try {
      final response = await dio.post(url,
          data: {'email': email, 'password': password, 'fcm_token': fcmToken});

      return AuthenticationModel.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.toString(), label: "error login datasource");
      throw (e.toString());
    }
  }

  @override
  Future<AuthenticationModelLogout> userLogout() async {
    final String url = '${AppConfig.baseURL}logout';
    final session = locator<Session>();
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.getToken}',
          },
        ),
      );

      return AuthenticationModelLogout.fromJson(response.data);
    } catch (e) {
      logger(e.toString(), label: "error logout datasource");
      throw e.toString();
    }
  }

  @override
  Future<AuthenticationModel> userRegister(String name, String email,
      String password, String cPassword, String alamat, String noTelp) async {
    final String url = '${AppConfig.baseURL}register';
    try {
      final response = await dio.post(url, data: {
        'nama': name,
        'email': email,
        'password': password,
        'alamat': alamat,
        'no_telp': noTelp,
        'password_confirmation': cPassword
      });

      return AuthenticationModel.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.toString(), label: "error register datasource");
      throw (e.toString());
    }
  }

  @override
  Future<AuthenticationModel> checkUserEmaill(String email) async {
    final String url = '${AppConfig.baseURL}check-email';
    try {
      final response = await dio.post(url, data: {'email': email});

      return AuthenticationModel.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.toString(), label: "error check email datasource");
      throw (e.toString());
    }
  }

  @override
  Future<AuthenticationModel> resetPassword(
      String email, String newPassword) async {
    final String url = '${AppConfig.baseURL}reset-password';
    try {
      final response = await dio
          .post(url, data: {'email': email, 'new_password': newPassword});
      return AuthenticationModel.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.toString(), label: "error reset password datasource");
      throw (e.toString());
    }
  }
}
