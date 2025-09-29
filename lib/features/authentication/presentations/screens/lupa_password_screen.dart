import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/features/authentication/presentations/bloc/authentication_bloc.dart';
import 'package:frontend/features/authentication/presentations/bloc/event/authentication_event.dart';
import 'package:frontend/features/authentication/presentations/bloc/state/authentication_state.dart';

class LupaPasswordScreen extends StatefulWidget {
  const LupaPasswordScreen({super.key});

  @override
  State<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen> {
  var _isEmailAvailable = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _onCheckEmailPressed() {
    final email = emailController.text;
    context.read<AuthenticationBloc>().add(
          CheckEmailEvent(email: email),
        );
  }

  void _onResetPassword(String email, String newPassword) {
    context.read<AuthenticationBloc>().add(
          ResetPasswordEvent(email: email, newPassword: newPassword),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationCheckEmailLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
            }
            if (state is AuthenticationCheckEmailSuccess) {
              Navigator.pop(context);
              setState(() {
                _isEmailAvailable = true;
              });
            }
            if (state is AuthenticationCheckEmailError) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
            }

            if (state is AuthenticationResetPasswordLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
            }
            if (state is AuthenticationResetPasswordSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.authenticationModelReset.message)),
              );
              Navigator.pop(context);
            }
            if (state is AuthenticationResetPasswordError) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
            }
          },
          child: SafeArea(
              child: Center(
                  child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lupa Password',
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.red,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Silahkan masukkan email Anda untuk mereset password'),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _isEmailAvailable
                    ? TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _isEmailAvailable
                        ? _onResetPassword(
                            emailController.text, passwordController.text)
                        : _onCheckEmailPressed();
                  },
                  child: _isEmailAvailable
                      ? Text(
                          'Reset Password',
                          style: TextStyle(color: white),
                        )
                      : Text(
                          'Check Email',
                          style: TextStyle(color: white),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Kembali ke Login',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              ],
            ),
          ))),
        ));
  }
}
