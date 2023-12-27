import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:lotto_flutter/screens/home_screen.dart';
import '../constants.dart';

class GameScreen extends StatefulWidget {
  final String token;
  final String game;

  const GameScreen({required this.token, required this.game, Key? key})
      : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<List<bool>> clickedStates =
      List.generate(5, (_) => List.generate(10, (_) => false));
  List<List> playedStates = List.generate(6, (_) => []);
  int playedStatesIndex = 0;
  List<bool> isReady = List.generate(6, (_) => false);
  List<List<bool>> isTapEnabled =
      List.generate(6, (_) => List.generate(10, (_) => true));
  List<List<List<int>>> disabledNumbers = List.generate(6, (_) => List.generate(10, (_) => []));
  int balanceInfo = 0;

  @override
  void initState() {
    super.initState();
  }

  void enableAllTaps() {
    for (int i = 0; i < isTapEnabled.length; i++) {
      for (int j = 0; j < isTapEnabled[i].length; j++) {
        setState(() {
          isTapEnabled[i][j] = true;
        });
      }
    }
  }

  Future<void> getBalanceInfo() async {
    final response = await http.post(
      Uri.parse('$mainUrl/api/v1/balance'),
      headers: <String, String>{
        'Authorization': "Bearer ${widget.token}",
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final success =
    responseBody['success'] as bool; // Set your error message here

    if (success) {
      print('balanceInfo:${responseBody['balance']}');
      setState(() {
        balanceInfo = responseBody['balance'];
      });
    } else {
      // Handle the error
      print('Failed to fetch profile: $responseBody');
    }
  }

  void enableOneTap(i, j) {
    setState(() {
      isTapEnabled[i][j] = true;
    });
  }

  Future<void> submitTicket() async {
    final response = await http.post(
      Uri.parse('$mainUrl/api/v1/tickets'),
      body: jsonEncode(<String, dynamic>{
        'game': widget.game,
        'numbers': [playedStates],
      }),
      headers: <String, String>{
        'Authorization': "Bearer ${widget.token}",
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final success =
        responseBody['success'] as bool; // Set your error message here
    final message =
        responseBody['message'] as String; // Set your error message here

    if (success) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(widget.token)));
      showSendMessage(context, message);
    } else {
      showErrorMessage(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 20.0),
              // Adjust the left margin as needed
              child: Text(
                '$balanceInfo Cr',
                style: const TextStyle(
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
                                  int rowIndex = j - 1;
                                  // Inside the onTap callback
                                  if (isTapEnabled[rowIndex][i - 1]) {
                                    int? blankIndex = playedStates[playedStatesIndex].indexOf('');

                                    if (blankIndex != -1) {
                                      playedStates[playedStatesIndex][blankIndex] = i + rowIndex * 10;
                                    } else {
                                      bool added = false;

                                      for (int lineIndex = 0; lineIndex < playedStates.length; lineIndex++) {
                                        int count = playedStates[lineIndex].where((e) => e != '').length;

                                        if (count < 6) {
                                          int? firstBlankIndex = playedStates[lineIndex].indexOf('');

                                          if (firstBlankIndex != -1) {
                                            playedStates[lineIndex][firstBlankIndex] = i + rowIndex * 10;
                                            added = true;
                                            break;
                                          }
                                        }
                                      }

                                      if (!added) {
                                        playedStates[playedStatesIndex].add(i + rowIndex * 10);
                                      }

                                      // Check if the current line is ready after adding elements
                                      isReady[playedStatesIndex] =
                                          playedStates[playedStatesIndex].where((e) => e != '').length >= 6;
                                    }

                                    clickedStates[rowIndex][i - 1] = !clickedStates[rowIndex][i - 1];
                                    isTapEnabled[rowIndex][i - 1] = false;

                                    if (playedStates[playedStatesIndex].length >= 6) {
                                      playedStatesIndex++;
                                      enableAllTaps();
                                      for (var row in clickedStates) {
                                        row.fillRange(0, row.length, false);
                                      }
                                    }

                                    // Check if any line is ready after adding or removing elements
                                    for (int lineIndex = 0; lineIndex < isReady.length; lineIndex++) {
                                      isReady[lineIndex] = playedStates[lineIndex].where((e) => e != '').length >= 6;
                                    }
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
                              ),
                            ),
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
                                      int x = max(
                                          ((playedStates[j - 1][i - 1] - 1)
                                                      .toInt() /
                                                  10)
                                              .floor(),
                                          0);
                                      if (playedStates[j - 1].isNotEmpty &&
                                          i <= playedStates[j - 1].length) {
                                        // When remove index, index value should set true of top
                                        enableOneTap(
                                            (x),
                                            ((playedStates[j - 1][i - 1] - 1)
                                                        .toInt() %
                                                    10)
                                                .floor());
                                        playedStates[j - 1][i - 1] = '';
                                        isReady[j - 1] = false;
                                      } else {
                                        // Add a blank item to playedStates
                                        playedStates[j - 1].add('');
                                        enableOneTap(
                                            (x),
                                            (playedStates[j - 1][i - 1]
                                                        .toInt() %
                                                    10)
                                                .floor());
                                        isReady[j - 1] = false;
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
                                              playedStates[j - 1].isNotEmpty &&
                                                      i <=
                                                          playedStates[j - 1]
                                                              .length
                                                  ? '${playedStates[j - 1][i - 1]}'
                                                  : ' ',
                                              // Display numbers from playedStates if available and within range, otherwise display an empty space
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
                              visible: isReady[j - 1],
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: Container(
                                width: 30, // Increased width
                                height: 48,
                                color: const Color(0xFFCC00FF),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Transform.rotate(
                                    angle: -1.5708, // Angle in radians for 90 degrees
                                    child: const Text(
                                      'READY',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                              backgroundColor: isReady[0]
                                  ? const Color(0xFFCC00FF)
                                  : const Color(0xFF4F4F4F),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              minimumSize: const Size(120, 45),
                            ),
                            onPressed: () {
                              submitTicket();
                            },
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
