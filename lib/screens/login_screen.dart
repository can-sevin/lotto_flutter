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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key
  final TextEditingController emailController = TextEditingController();

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
    final success =
        responseBody['success'] as bool; // Set your error message here
    final int? code = responseBody['code'];
    final errorMessage =
    responseBody['message'] as String; // Set your error message here

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OtpScreen(email, null)),
      );
    } else if ([2025, 2026].contains(code)) {
      showErrorMessage(context, errorMessage);
    } else if ([2023].contains(code)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RegisterScreen(email)),
      );
    } else if ([2009, 2010].contains(code)) {
      final errorMessage =
          responseBody['message'] as String; // Set your error message here
      showErrorMessage(context, errorMessage);
    } else {
      showErrorMessage(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          Form(
            key: _formKey, // Assign the global key to the form
            child: Stack(
              children: [
                Container(
                  alignment: const Alignment(0.0, -0.2),
                  child: SizedBox(
                    height: 120.0,
                    width: 320.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Are you sure your email type?';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: const Alignment(0.0, 0.1),
                  child: TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final String email = emailController.text;
                        await getOtpCode(context, email);
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
          ),
        ],
      ),
    );
  }
}
