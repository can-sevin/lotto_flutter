import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:lotto_flutter/screens/otp_screen.dart';
import 'package:lotto_flutter/screens/register_screen.dart';

import '../constants.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final Logger logger = Logger();

  Future<void> getOtpCode(BuildContext context, String email) async {
    final response = await http.post(
      Uri.parse('$mainUrl/api/v1/auth/login/email'),
      body: jsonEncode(<String, String>{
        'email': email,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final int code = responseBody['code'] as int;

    if (code == 2023) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RegisterScreen(email)),
      );
    } else if ([2025, 2026].contains(code)) {
      final errorMessage = responseBody['message'] as String; // Set your error message here
      showErrorMessage(context, errorMessage);
    } else if ([200, 2024].contains(code)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OtpScreen(email, null)),
      );
    } else if ([2009, 2010].contains(code)) {
      final errorMessage = responseBody['message'] as String; // Set your error message here
      showErrorMessage(context, errorMessage);
    }
  }

  final TextEditingController emailController = TextEditingController();

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red, // Customize the background color
        duration: const Duration(seconds: 3), // Adjust the duration as needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 0.4],
                colors: [
                  Color(0xFFCC00FF),
                  Color(0xFF1E1E1E),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                alignment: const Alignment(0.0, -0.25),
                child: SizedBox(
                  height: 49.0,
                  width: 320.0,
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter your email',
                    ),
                  ),
                ),
              ),
              Container(
                alignment: const Alignment(0.0, 0.1),
                child: TextButton(
                  onPressed: () async {
                    final String email = emailController.text;
                    if (email.isNotEmpty) {
                      await getOtpCode(context, email);
                    } else {
                      const errorMessage = "Email line blank?"; // Set your error message here
                      showErrorMessage(context, errorMessage);
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    minimumSize: const Size(158, 60),
                  ),
                  child: const Text(
                    'Send code',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: const Alignment(0.0, 0.9),
                child: Image.asset(
                  'assets/images/lotto_bottom_logo.png',
                  fit: BoxFit.none,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
