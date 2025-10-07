import 'package:dio/dio.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/authentication/data/models/authentication_model.dart';

abstract class AuthenticationDatasource {
  Future<AuthenticationModel> userLogin(
      String email, String password, String fcmToken, String phoneId);
  Future<AuthenticationModelLogout> userLogout();
  Future<AuthenticationModel> userRegister(
      String name, String email, String password, String cPassword);
  Future<AuthenticationModel> checkUserEmaill(String email);
  // Future<AuthenticationModel> resetPassword(String email, String newPassword);
  Future<String> resendVerification(String email);
  Future<String> forgotPassword(String email);
  Future<String> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });
  Future<String> verifyEmail(String token);
}

class AuthenticationDataSourceImpl implements AuthenticationDatasource {
  final Dio dio;
  AuthenticationDataSourceImpl({required this.dio});

  @override
  Future<AuthenticationModel> userLogin(
      String email, String password, String fcmToken, String phoneId) async {
    final String url = '${AppConfig.baseURL}login';
    try {
      final response = await dio.post(url, data: {
        'email': email,
        'password': password,
        'fcm_token': fcmToken,
        'phone_id': phoneId
      });

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
  Future<AuthenticationModel> userRegister(
      String name, String email, String password, String cPassword) async {
    final String url = '${AppConfig.baseURL}register';
    try {
      final response = await dio.post(url, data: {
        'nama': name,
        'email': email,
        'password': password,
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
  Future<String> resendVerification(String email) async {
    try {
      final response = await dio.post(
        '${AppConfig.baseURL}resend-verification',
        data: {'email': email},
      );

      if (response.data['status'] == 200) {
        return response.data['message'];
      } else {
        throw ServerFailure(
          message:
              response.data['message'] ?? 'Gagal mengirim email verifikasi',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await dio.post(
        '${AppConfig.baseURL}forgot-password',
        data: {'email': email},
      );

      if (response.data['status'] == 200) {
        return response.data['message'];
      } else {
        throw ServerFailure(
          message:
              response.data['message'] ?? 'Gagal mengirim email reset password',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<String> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        '${AppConfig.baseURL}reset-password',
        data: {
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.data['status'] == 200) {
        return response.data['message'];
      } else {
        throw ServerFailure(
          message: response.data['message'] ?? 'Gagal reset password',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<String> verifyEmail(String token) async {
    try {
      final response = await dio.get('${AppConfig.baseURL}verify-email/$token');

      if (response.data['status'] == 200) {
        return response.data['message'];
      } else {
        throw ServerFailure(
          message: response.data['message'] ?? 'Gagal verifikasi email',
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }
}
