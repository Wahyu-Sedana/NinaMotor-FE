import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';

class AppInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.addAll({"content-type": "application/json; charset=utf-8"});
    options.headers.addAll({"Accept": "application/json"});

    final Session session = await locator.getAsync<Session>();
    final String accessToken = session.getToken;

    if (accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      logger("Authorization: Bearer $accessToken", label: 'access-token');
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger(
      "Dio Error: ${err.message}, Status: ${err.response?.statusCode}",
      label: 'dio-error',
    );

    final message = err.type == DioExceptionType.connectionError
        ? 'Tidak dapat terhubung ke server.'
        : err.message ?? 'Terjadi kesalahan jaringan.';

    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );

    return super.onError(err, handler);
  }
}
