import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/authentication/presentations/bloc/authentication_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/kategori_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:frontend/features/profile/presentations/bloc/profile_bloc.dart';
import 'package:frontend/features/routes/route.dart';
import 'package:frontend/features/servismotor/presentations/bloc/service_motor_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await locatorInit();
  await locator.isReady<Session>();
  try {
    runApp(const MainApp());
  } catch (e) {
    logger(e.toString(), label: "error");
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthenticationBloc(
              authenticationUsecaseImpl: locator(),
            ),
          ),
          BlocProvider(
            create: (context) => SparepartBloc(
              sparepartUsecaseImpl: locator(),
            ),
          ),
          BlocProvider(
            create: (context) => KategoriBloc(
              kategoriUsecaseImpl: locator(),
            ),
          ),
          BlocProvider(
              create: (context) => ProfileBloc(profileUsecaseImpl: locator())),
          BlocProvider(
              create: (context) => MotorServiceBloc(usecase: locator()))
        ],
        child: MaterialApp(
          navigatorObservers: [routeObserver],
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: RouteService.generateRoute,
        ));
  }
}
