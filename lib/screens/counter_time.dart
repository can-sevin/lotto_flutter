import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:logger/logger.dart';
import 'package:lotto_flutter/screens/home_screen.dart';
import 'package:lotto_flutter/screens/login_screen.dart';
import '../constants.dart';

import 'dart:convert';
import 'dart:async';

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

class CountdownTimer extends StatefulWidget {
  final String email; // Declare email as an instance variable
  final Map<String, String>?
      responseBody; // Declare email as an instance variable
  final Logger logger = Logger();

  CountdownTimer(this.email, this.responseBody, {Key? key}) : super(key: key);

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer> {
  int _secondsRemaining = 180; // Initial time in seconds
  late Timer _timer;
  bool _resend = false;

  Future<void> registerUser(
      BuildContext context,
      String email,
      String name,
      String lastName,
      String phoneNumber,
      String cityId,
      String birthDate,
      String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$mainUrl/api/v1/auth/register/email/otp'),
        body: jsonEncode(<String, String>{
          'name': name,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'cityId': cityId,
          'birthDate': birthDate,
          'otp': otpCode,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final success = responseBody['success'] as bool;
        final int? code = responseBody['code'];
        final errorMessage = responseBody['message'] as String;
        final token = responseBody['token'];

        // Process the response data based on your logic
        if (success) {
          // Handle success
        } else {
          // Handle failure
          print('Error Code: $code, Message: $errorMessage');
        }
      } else {
        // Handle non-200 status code
        print('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
      // Handle the error gracefully
    }
  }

  Future<void> loginUser(
      BuildContext context, String email, String otpCode) async {
    final response = await http.post(
      Uri.parse('$mainUrl/api/v1/auth/login/email/otp'),
      body: jsonEncode(<String, String>{
        'email': email,
        'otp': otpCode,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final success =
        responseBody['success'] as bool; // Set your error message here
    final int? code = responseBody['code'];
    final dynamic data = responseBody['data'];

    final errorMessage =
        responseBody['message'] as String; // Set your error message here

    if (success) {
      final tokenInfo = data['token'];
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(tokenInfo)));
      showSendMessage(context, errorMessage);
    } else if ([2015, 2016, 2017, 2018, 2019, 2099].contains(code)) {
      showErrorMessage(context, errorMessage);
      _resend = true;
      _secondsRemaining = 180;
    } else {
      showErrorMessage(context, errorMessage);
    }
  }

  Future<void> getOtpCodeLogin(BuildContext context, String email) async {
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
      showSendMessage(context, errorMessage);
      _resend = false;
      _secondsRemaining = 180;
    } else if ([2025, 2026].contains(code)) {
      final errorMessage =
          responseBody['message'] as String; // Set your error message here
      showErrorMessage(context, errorMessage);
    } else if ([2023].contains(code)) {
      showErrorMessage(context, errorMessage);
    } else if ([2009, 2010].contains(code)) {
      final errorMessage =
          responseBody['message'] as String; // Set your error message here
      showErrorMessage(context, errorMessage);
    } else {
      showErrorMessage(context, errorMessage);
    }
  }

  Future<void> getOtpCodeRegister(
      BuildContext context,
      String email,
      String name,
      String lastName,
      String phoneNumber,
      String cityId,
      String birthDate) async {
    final requestScheme = <String, String>{
      'name': name,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'cityId': cityId,
      'birthDate': birthDate,
    };

    final response = await http.post(
      Uri.parse('$mainUrl/api/v1/auth/register/email'),
      body: jsonEncode(requestScheme),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);

    final errorMessage =
        responseBody['message'] as String; // Set your error message here
    final success =
        responseBody['success'] as bool; // Set your error message here
    final int? code = responseBody['code'];

    if (success) {
      showSendMessage(context, errorMessage);
      _resend = false;
      _secondsRemaining = 180;
    } else if ([2009, 2010, 2011, 2012, 2013, 2014].contains(code)) {
      showErrorMessage(context, errorMessage);
    } else {
      showErrorMessage(context, errorMessage);
    }
  }

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

  String getAllTextFieldsValue() {
    return _controllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = (_secondsRemaining).toString().padLeft(2, '0');
    return Container(
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
        child: Stack(
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 1.0),
                      filled: true,
                      fillColor: _resend
                          ? const Color(0xFF5C5C5C)
                          : Colors.purpleAccent,
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
            Align(
                alignment: Alignment.center,
                child: _resend
                    ? null
                    : const SizedBox(
                        width: 92,
                        height: 92,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.purple),
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
                      onPressed: () async {
                        widget.responseBody == null
                            ? await getOtpCodeLogin(
                                context,
                                widget.email,
                              )
                            : await getOtpCodeRegister(
                                context,
                                widget.email,
                                widget.responseBody!['name']!,
                                widget.responseBody!['lastName']!,
                                widget.responseBody!['phoneNumber']!,
                                widget.responseBody!['cityId']!,
                                widget.responseBody!['birthDate']!);
                      },
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 20),
                      ),
                    )
                  : GestureDetector(
                      onTap: _resend
                          ? null
                          : () {
                              // Your onPressed logic here
                              // For example, you can navigate to a new screen or perform any action
                              widget.responseBody == null
                                  ? loginUser(context, widget.email,
                                      getAllTextFieldsValue())
                                  : registerUser(
                                      context,
                                      widget.email,
                                      widget.responseBody!['name']!,
                                      widget.responseBody!['lastName']!,
                                      widget.responseBody!['phoneNumber']!,
                                      widget.responseBody!['cityId']!,
                                      widget.responseBody!['birthDate']!,
                                      getAllTextFieldsValue());
                            },
                      child: SizedBox(
                          width: 96,
                          height: 96,
                          child: Image.asset(
                            'assets/images/tickcircle.png',
                            fit: BoxFit.none,
                          ))),
            ),
            Align(
              alignment: Alignment.center,
              child: _resend
                  ? null
                  : SizedBox(
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
                _resend
                    ? 'Your time runned out'
                    : 'We sent a 4-digit code ${widget.email} check your mailbox',
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
        ));
  }
}
