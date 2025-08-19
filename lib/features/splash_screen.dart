import 'package:flutter/material.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/cores/utils/strings.dart';
import 'package:frontend/features/routes/route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    final session = locator<Session>();
    // final token = session.getToken;

    // if (token.isNotEmpty) {
    //   Future.delayed(const Duration(seconds: 3), () {
    //     Navigator.pushReplacementNamed(context, RouteService.homeRoute);
    //   });
    // } else {
    //   Future.delayed(const Duration(seconds: 3), () {
    //     Navigator.pushReplacementNamed(context, RouteService.onboardingRoute);
    //   });
    // }

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, RouteService.homeRoute);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [white, gray],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Image.asset(
              logoName,
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
