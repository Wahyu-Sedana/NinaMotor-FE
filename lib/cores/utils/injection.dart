import 'package:dio/dio.dart';
import 'package:frontend/features/home/data/datasources/kategori_produk_datasource.dart';
import 'package:frontend/features/home/data/datasources/produk_datasource.dart';
import 'package:frontend/features/home/data/repositories/kategori_repository.dart';
import 'package:frontend/features/home/data/repositories/produk_repository.dart';
import 'package:frontend/features/home/domain/usecases/kategori_usecase.dart';
import 'package:frontend/features/home/domain/usecases/produk_usecase.dart';
import 'package:frontend/features/home/presentations/bloc/kategori_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/cores/services/dio_client.dart';
import 'package:frontend/cores/utils/session.dart';

// AUTH
import 'package:frontend/features/authentication/data/datasources/authentication_datasource.dart';
import 'package:frontend/features/authentication/data/repositories/authentication_repository.dart';
import 'package:frontend/features/authentication/domain/usecases/authentication_usecase.dart';
import 'package:frontend/features/authentication/presentations/bloc/authentication_bloc.dart';

final locator = GetIt.instance;

Future<void> locatorInit() async {
  // Core
  locator.registerLazySingleton<Dio>(() => DioClient().dio);
  locator.registerLazySingletonAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance());
  locator.registerLazySingletonAsync<Session>(() async =>
      SessionImpl(pref: await locator.getAsync<SharedPreferences>()));

  // Bloc
  locator.registerFactory<AuthenticationBloc>(
    () => AuthenticationBloc(authenticationUsecaseImpl: locator()),
  );
  locator.registerFactory<SparepartBloc>(
    () => SparepartBloc(sparepartUsecaseImpl: locator()),
  );
  locator.registerFactory<KategoriBloc>(
    () => KategoriBloc(kategoriUsecaseImpl: locator()),
  );

  // Auth Feature
  locator.registerLazySingleton<AuthenticationDatasource>(
      () => AuthenticationDataSourceImpl(dio: locator<Dio>()));
  locator.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      authenticationDatasource: locator<AuthenticationDatasource>(),
    ),
  );
  locator.registerLazySingleton<AuthenticationUsecaseImpl>(
      () => AuthenticationUsecaseImpl(authenticationRepository: locator()));

  // Sparepart Feature
  locator.registerLazySingleton<SparepartDatasource>(
      () => SparepartDataSourceImpl(dio: locator<Dio>()));
  locator.registerLazySingleton<SparepartRepository>(
    () => SparepartRepositoryImpl(sparepartDatasource: locator()),
  );
  locator.registerLazySingleton<SparepartUsecaseImpl>(
    () => SparepartUsecaseImpl(repository: locator()),
  );

  // Kategori Feature
  locator.registerLazySingleton<KategoriDatasource>(
      () => KategoriDataSourceImpl(dio: locator<Dio>()));
  locator.registerLazySingleton<KategoriRepository>(
    () => KategoriRepositoryImpl(kategoriDatasource: locator()),
  );
  locator.registerLazySingleton<KategoriUsecaseImpl>(
    () => KategoriUsecaseImpl(repository: locator()),
  );
}
