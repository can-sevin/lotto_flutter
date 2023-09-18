import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({Key? key}) : super(key: key);

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer> {
  int _secondsRemaining = 180; // Initial time in seconds
  late Timer _timer;
  bool _resend = false;

  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();

    // Start the countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _resend = true;
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    for (int i = 0; i < 4; i++) {
      _controllers[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = (_secondsRemaining).toString().padLeft(2, '0');

    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Container(
              height: 90.0,
              width: 60.0,
              alignment: Alignment.center,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                showCursor: false,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60.0,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  MaxLengthFormatter(1)
                ],
                onChanged: (String value) {
                  if (value.isNotEmpty) {
                    // When content is entered, focus on the next field
                    if (index < 3) {
                      FocusScope.of(context)
                          .requestFocus(_focusNodes[index + 1]);
                    }
                  } else {
                    // When content is deleted, focus on the previous field
                    if (index > 0) {
                      FocusScope.of(context)
                          .requestFocus(_focusNodes[index - 1]);
                    }
                  }
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  filled: true,
                  fillColor:
                      _resend ? const Color(0xFF5C5C5C) : Colors.purpleAccent,
                  labelStyle: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 60,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
              ),
            );
          }),
        ),
        const Align(
            alignment: Alignment.center,
            child: SizedBox(
                width: 92,
                height: 92,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  strokeWidth: 5,
                ))),
        Align(
          alignment: const Alignment(0.0, -0.45),
          child: _resend
              ? TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF4F4F4F),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    minimumSize: const Size(158, 60),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                )
              : SizedBox(
                  width: 96,
                  height: 96,
                  child: Image.asset(
                    'assets/images/tickcircle.png',
                    fit: BoxFit.none,
                  )),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 72,
            height: 48,
            child: Text(
              formattedTime,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
        Container(
          alignment: const Alignment(0.0, 0.5),
          padding: const EdgeInsets.all(28),
        ),
        Container(
          alignment: const Alignment(0.0, 0.65),
          padding: const EdgeInsets.all(28),
          child: Text(
            _resend ? 'Your time runned out ' : 'We sent a 4-digit code xxx@gmail.com check your mailbox',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class MaxLengthFormatter extends TextInputFormatter {
  final int maxLength;

  MaxLengthFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > maxLength) {
      return oldValue;
    }
    return newValue;
  }
}
