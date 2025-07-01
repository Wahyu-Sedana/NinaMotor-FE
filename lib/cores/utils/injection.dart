import 'package:dio/dio.dart';
import 'package:frontend/cores/services/dio_client.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/authentication/data/datasources/authentication_datasource.dart';
import 'package:frontend/features/authentication/data/repositories/authentication_repository.dart';
import 'package:frontend/features/authentication/domain/usecases/authentication_usecase.dart';
import 'package:frontend/features/authentication/presentations/bloc/authentication_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;
Future<void> locatorInit() async {
  locator.registerLazySingleton<Dio>(() => DioClient().dio);
  locator.registerLazySingletonAsync<Session>(() async =>
      SessionImpl(pref: await locator.getAsync<SharedPreferences>()));
  locator.registerLazySingletonAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance());

  // Bloc
  locator.registerFactory<AuthenticationBloc>(
    () => AuthenticationBloc(authenticationUsecaseImpl: locator()),
  );

  // DataSource
  locator.registerLazySingleton<AuthenticationDatasource>(
      () => AuthenticationDataSourceImpl(dio: locator<Dio>()));

  // Repository
  locator.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      authenticationDatasource: locator<AuthenticationDatasource>(),
    ),
  );

  // UseCase
  locator.registerLazySingleton<AuthenticationUsecaseImpl>(
      () => AuthenticationUsecaseImpl(authenticationRepository: locator()));
}
