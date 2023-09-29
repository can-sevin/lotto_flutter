import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:lotto_flutter/screens/otp_screen.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger logger = Logger();
  int selectedIndex = 0;
  late PageController _pageControllerTop =
      PageController(viewportFraction: 0.8, initialPage: 0);
  late PageController _pageControllerBottom =
      PageController(viewportFraction: 0.8, initialPage: 0);
  int activePageTop = 0;
  int activePageBottom = 0;
  List<String> images = [
    'assets/images/fortuna.png',
    'assets/images/felkitas.png',
    'assets/images/nortia.png'
  ];

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
    _pageControllerTop = PageController(viewportFraction: 0.8);
    _pageControllerBottom = PageController(viewportFraction: 0.8);
    super.initState();
  }

  List<Widget> indicators(imagesLength, currentIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: const EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: currentIndex == index ? Colors.white : Colors.black87,
            shape: BoxShape.circle),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 60,
        animationDuration: const Duration(milliseconds: 1000),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_filled), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Results'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile')
        ],
        selectedIndex: selectedIndex,
      ),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 12.0),
              // Adjust the left margin as needed
              child: Image.asset(
                'assets/images/lotto_bottom_logo.png',
                fit: BoxFit.none,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 20.0),
                // Adjust the left margin as needed
                child: Image.asset(
                  'assets/images/profilecircle.png',
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 212,
                        width: MediaQuery.of(context).size.width,
                        child: PageView.builder(
                          itemCount: images.length,
                          pageSnapping: true,
                          controller: _pageControllerTop,
                          onPageChanged: (page) {
                            setState(() {
                              activePageTop = page;
                            });
                          },
                          itemBuilder: (context, pagePosition) {
                            return Stack(
                              children: [
                                Container(
                                  height: 212,
                                  margin: const EdgeInsets.all(16),
                                  child: Image.asset(
                                    images[pagePosition],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const Positioned(
                                  bottom: 48, // Adjust the position as needed
                                  left: 70,
                                  child: Text(
                                    '999,999,999 \$',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 20, // Adjust the position as needed
                                  left: 24, // Adjust the position as needed
                                  child: Text(
                                    'remains  6h 2d 4w',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: indicators(images.length, activePageTop)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Results",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 32,
                          )),
                      SizedBox(
                        height: 212,
                        width: MediaQuery.of(context).size.width,
                        child: PageView.builder(
                          itemCount: images.length,
                          pageSnapping: true,
                          controller: _pageControllerBottom,
                          onPageChanged: (page) {
                            setState(() {
                              activePageBottom = page;
                            });
                          },
                          itemBuilder: (context, pagePosition) {
                            return Stack(
                              children: [
                                Container(
                                  height: 212,
                                  margin: const EdgeInsets.all(16),
                                  child: Image.asset(
                                    images[pagePosition],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const Positioned(
                                  top: 24,
                                  right: 24, // Adjust the position as needed
                                  child: Text(
                                    '27/12/2023',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 48, // Adjust the position as needed
                                  left: 70,
                                  child: Text(
                                    '999,999,999 \$',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 20, // Adjust the position as needed
                                  left: 36, // Adjust the position as needed
                                  child: Text(
                                    '30-36-23-33-44-55',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              indicators(images.length, activePageBottom)),
                    ],
                  )
                ],
              )),
        ],
      ),
    );
  }
}
