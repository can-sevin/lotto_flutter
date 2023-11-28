import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:lotto_flutter/screens/home_screen.dart';

import '../constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<List<bool>> clickedStates = List.generate(5, (_) => List.generate(10, (_) => false));
  List<List> playedStates = List.generate(5, (_) => []);
  int playedStatesIndex = 0;
  List<bool> isReady = List.generate(5, (_) => false);

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('playedStates: $playedStates');
    print('isReady: $isReady');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: <Widget>[
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
        SafeArea(
            child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 12.0),
            // Adjust the left margin as needed
            child: Image.asset(
              'assets/images/lotto_bottom_logo.png',
              fit: BoxFit.none,
            ),
          ),
        )),
        const SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20.0, top: 20.0),
              // Adjust the left margin as needed
              child: Text(
                '0 Cr',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 24),
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 160.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int j = 1; j <= 5; j++)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 1; i <= 10; i++)
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    clickedStates[j - 1][i - 1] = !clickedStates[j - 1][i - 1];
                                    if (clickedStates[j - 1][i - 1]) {
                                      playedStates[playedStatesIndex].add(i + (j - 1) * 10);
                                      playedStates[playedStatesIndex] = playedStates[playedStatesIndex].toList();
                                    }
                                    else if (clickedStates[j - 1][i - 1]) {
                                      playedStates[playedStatesIndex].add(i + (j - 1) * 10);
                                      playedStates[playedStatesIndex] = playedStates[playedStatesIndex].toList();
                                    }
                                    if (playedStates[playedStatesIndex].length >= 6) {
                                      isReady[playedStatesIndex] = true;
                                      playedStatesIndex++;
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: clickedStates[j - 1][i - 1]
                                              ? const Color(0x4F4F4F00)
                                              : const Color(0xFFCC00FF),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + (j - 1) * 10}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                        ],
                      ),
                  ],
                )),
            Container(
              height: 360,
              width: MediaQuery.of(context).size.width,
              color: const Color(0x703B3B3B),
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (int j = 1; j <= 4; j++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 1; i <= 6; i++)
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (playedStates[j - 1].isNotEmpty && i <= playedStates[j - 1].length) {
                                        // Replace the tapped item with a blank item of the same size
                                        playedStates[j - 1][i - 1] = '';
                                        isReady[j-1] = false;
                                      } else {
                                        // Add a blank item to playedStates
                                        playedStates[j - 1].add('');
                                        isReady[j-1] = false;
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF676767),
                                          ),

                                          child: Center(
                                            child: Text(
                                              playedStates[j - 1].isNotEmpty && i <= playedStates[j - 1].length
                                                  ? '${playedStates[j - 1][i - 1]}'
                                                  : ' ', // Display numbers from playedStates if available and within range, otherwise display an empty space
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            Visibility(
                              visible: isReady[j-1],
                              child: Container(
                              width: 20, // Increase the width as needed
                              height: 48,
                              color: const Color(0xFFCC00FF),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Transform.rotate(
                                  angle: -1.5708, // Angle in radians for 90 degrees
                                  child: const Text(
                                    'OK',
                                    textAlign: TextAlign.center,
                                    maxLines: 1, // Display only one line
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 28.0, right: 28.0),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: isReady[0] ? const Color(0xFFCC00FF) : const Color(0xFF4F4F4F),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              minimumSize: const Size(120, 45),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: 20),
                            ),
                   ))),
                ],
              ),
            )
          ],
        )
      ]),
    );
  }
}
