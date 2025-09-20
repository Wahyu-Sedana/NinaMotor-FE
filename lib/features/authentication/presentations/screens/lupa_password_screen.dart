import 'package:flutter/material.dart';
import 'package:frontend/cores/utils/colors.dart';

class LupaPasswordScreen extends StatefulWidget {
  const LupaPasswordScreen({super.key});

  @override
  State<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen> {
  final _isEmailAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
              controller: null,
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
                ? Text(
                    'Email ditemukan. Silakan cek inbox Anda untuk instruksi selanjutnya.',
                    style: TextStyle(color: Colors.green),
                  )
                : SizedBox(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text(
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
                style: TextStyle(color: Colors.blueGrey),
              ),
            )
          ],
        ),
      ))),
    );
  }
}
