import 'package:flutter/material.dart';
import 'counter_time.dart';

class OtpScreen extends StatelessWidget {
  final String email; // Declare email as an instance variable
  final Map<String, String>? responseBody; // Declare email as an instance variable
  const OtpScreen(this.email, this.responseBody, {Key? key}) : super(key: key);

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
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.1, 0.4],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Color(0xFFCC00FF),
                Color(0xFF1E1E1E),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 124.0),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              CountdownTimer(email, responseBody),
              Container(
                alignment: const Alignment(0.0, 0.9),
                child: Image.asset(
                  'assets/images/lotto_bottom_logo.png',
                  fit: BoxFit.none,
                ),
              )
            ],
          ),
        )
      ],
    ));
  }
}