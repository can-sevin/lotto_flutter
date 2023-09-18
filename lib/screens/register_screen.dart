import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

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
        Stack(
          children: [
            Container(
                alignment: const Alignment(0.0, -0.8),
                child: const SizedBox(
                    height: 49.0,
                    width: 320.0,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Enter your name',
                        labelStyle: TextStyle(
                            color: Color(0xFF5C5C5C),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ))),
            Container(
                alignment: const Alignment(0.0, -0.6),
                child: const SizedBox(
                    height: 49.0,
                    width: 320.0,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Enter your surname',
                        labelStyle: TextStyle(
                            color: Color(0xFF5C5C5C),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ))),
            Container(
                alignment: const Alignment(0.0, -0.4),
                child: const SizedBox(
                    height: 49.0,
                    width: 320.0,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Enter your phone',
                        labelStyle: TextStyle(
                            color: Color(0xFF5C5C5C),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ))),
            Container(
                alignment: const Alignment(0.0, -0.2),
                child: const SizedBox(
                    height: 49.0,
                    width: 320.0,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Select your city',
                        labelStyle: TextStyle(
                            color: Color(0xFF5C5C5C),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ))),
            Container(
                alignment: const Alignment(0.0, 0.0),
                child: const SizedBox(
                    height: 49.0,
                    width: 320.0,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Select birthday',
                        labelStyle: TextStyle(
                            color: Color(0xFF5C5C5C),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ))),
            Container(
                alignment: const Alignment(0.0, 0.65),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    minimumSize: const Size(320, 60),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                )),
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
    ));
  }
}
