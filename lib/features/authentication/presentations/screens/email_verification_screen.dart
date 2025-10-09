import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/authentication/presentations/bloc/authentication_bloc.dart';
import 'package:frontend/features/authentication/presentations/bloc/event/authentication_event.dart';
import 'package:frontend/features/authentication/presentations/bloc/state/authentication_state.dart';
import 'package:frontend/features/routes/route.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _canResend = true;
  int _countdown = 0;

  @override
  Widget build(BuildContext context) {
    final redColor = Colors.red.shade600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is ResendVerificationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _startCountdown();
          }

          if (state is ResendVerificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔹 Logo Bulat dengan Gradient
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [redColor, Colors.redAccent.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 🔹 Judul
                  Text(
                    "Verifikasi Email Anda",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kami telah mengirimkan tautan verifikasi ke email Anda:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: redColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 🔹 Card Info
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Info Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.amber.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Periksa folder spam jika email tidak ditemukan.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Tombol Kirim Ulang
                        BlocBuilder<AuthenticationBloc, AuthenticationState>(
                          builder: (context, state) {
                            final isLoading =
                                state is ResendVerificationLoading;

                            if (_canResend) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      isLoading ? null : _resendVerification,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    backgroundColor: redColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Kirim Ulang Email",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              );
                            } else {
                              return Text(
                                'Kirim ulang dalam $_countdown detik',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🔹 Back to Login
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteService.loginRoute,
                        (route) => false,
                      );
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: redColor),
                    label: Text(
                      "Kembali ke Login",
                      style: TextStyle(
                        color: redColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resendVerification() {
    context.read<AuthenticationBloc>().add(
          ResendVerificationEvent(email: widget.email),
        );
  }

  void _startCountdown() {
    setState(() {
      _canResend = false;
      _countdown = 60;
    });
    Future.delayed(const Duration(seconds: 1), _updateCountdown);
  }

  void _updateCountdown() {
    if (_countdown > 0) {
      setState(() => _countdown--);
      Future.delayed(const Duration(seconds: 1), _updateCountdown);
    } else {
      setState(() => _canResend = true);
    }
  }
}
