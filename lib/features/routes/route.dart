import 'package:flutter/material.dart';
import 'package:frontend/cores/presentations/screens/onboarding_screen.dart';
import 'package:frontend/features/authentication/presentations/screens/login_screen.dart';
import 'package:frontend/features/authentication/presentations/screens/register_screen.dart';
import 'package:frontend/features/home/presentations/screens/home_screen.dart';
import 'package:frontend/features/home/presentations/screens/produk_list_screen.dart';
import 'package:frontend/features/pembayaran/presentations/screens/history_pembayaran.dart';
import 'package:frontend/features/splash_screen.dart';

class RouteService {
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String listProdukRoute = '/list-produk';
  static const String historyPembyaranRoute = '/history-pembayaran';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case listProdukRoute:
        return MaterialPageRoute(builder: (_) => const ProdukListScreen());
      case historyPembyaranRoute:
        return MaterialPageRoute(
            builder: (_) => const TransactionHistoryScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Halaman tidak ditemukan'),
            ),
          ),
        );
    }
  }
}
