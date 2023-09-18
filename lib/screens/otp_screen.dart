import 'package:flutter/material.dart';

import 'counter_time.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({Key? key}) : super(key: key);

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
              const CountdownTimer(),
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