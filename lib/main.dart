import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/firebase_options.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/notification_helper.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/authentication/presentations/bloc/authentication_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/kategori_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/review_bloc.dart';
import 'package:frontend/features/pembayaran/presentations/bloc/checkout_bloc.dart';
import 'package:frontend/features/profile/presentations/bloc/profile_bloc.dart';
import 'package:frontend/features/routes/route.dart';
import 'package:frontend/features/servismotor/presentations/bloc/service_motor_bloc.dart';

Future<void> onBackgroundMessageHandler(RemoteMessage message) async {}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    logger("Firebase initialized successfully", label: "firebase");
  } catch (e) {
    logger("Failed to initialize Firebase: ${e.toString()}",
        label: "firebase_error");
  }
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  if (Platform.isAndroid || Platform.isIOS) {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
  }
  await locatorInit();
  await locator.isReady<Session>();
  try {
    await NotificationHelper().init();
    logger("Notification helper initialized successfully",
        label: "notification");
  } catch (e) {
    logger("Failed to initialize notification helper: ${e.toString()}",
        label: "notification_error");
  }
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
              create: (context) => MotorServiceBloc(usecase: locator())),
          BlocProvider(
              create: (context) =>
                  CheckoutBloc(transactionUsecaseImpl: locator())),
          BlocProvider(
              create: (context) => ReviewBloc(reviewUsecaseImpl: locator())),
        ],
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          navigatorObservers: [routeObserver],
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: RouteService.generateRoute,
        ));
  }
}
