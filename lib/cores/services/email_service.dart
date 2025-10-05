import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';

class EmailService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> resendVerification(String email) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseURL}/resend-verification',
        data: {'email': email},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to resend verification email: $e');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseURL}/forgot-password',
        data: {'email': email},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to send reset password email: $e');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseURL}/reset-password',
        data: {
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
}
