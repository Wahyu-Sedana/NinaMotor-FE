import 'package:dio/dio.dart';
import 'package:frontend/cores/services/dio_client.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

Future<void> locatorInit() async {
  locator.registerLazySingleton<Dio>(() => DioClient().dio);
  locator.registerLazySingletonAsync<Session>(() async =>
      SessionImpl(pref: await locator.getAsync<SharedPreferences>()));
  locator.registerLazySingletonAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance());
}
