import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen(this.token, {Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger logger = Logger();
  List<Map<String, dynamic>> gameList = [];
  int selectedIndex = 0;
  late PageController _pageControllerTop =
      PageController(viewportFraction: 0.8, initialPage: 0);
  late PageController _pageControllerBottom =
      PageController(viewportFraction: 0.8, initialPage: 0);
  int activePageTop = 0;
  int activePageBottom = 0;
  late Map<String, dynamic> profileInfo;

  Future<void> getAllGames() async {
    final response = await http.get(
      Uri.parse('$mainUrl/api/v1/games'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final success =
        responseBody['success'] as bool; // Set your error message here

    if (success) {
      setState(() {
        gameList = (responseBody['gameList'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
      });
    } else {
      // Handle the error
      print('Failed to fetch games: ${response.statusCode}');
    }
  }

  Future<void> getProfileInfo() async {
    final response = await http.post(
      Uri.parse('$mainUrl/api/v1/profile/user'),
      headers: <String, String>{
        'Authorization': "Bearer ${widget.token}",
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final success =
        responseBody['success'] as bool; // Set your error message here
    final code = responseBody['code']; // Set your error message here

    if (success) {
      profileInfo = responseBody['data'];
      print('Profileeeee: $responseBody');
    } else {
      // Handle the error
      print('Failed to fetch profile: $responseBody');
    }
  }

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
    getAllGames();
    getProfileInfo();
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

  Widget mainPage() {
    return Stack(
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
                        itemCount: gameList.length,
                        pageSnapping: true,
                        controller: _pageControllerTop,
                        onPageChanged: (page) {
                          setState(() {
                            activePageTop = page;
                          });
                        },
                        itemBuilder: (context, pagePosition) {
                          final game = gameList[pagePosition];
                          final dynamic prize = game['prize'].toString();
                          final dynamic image =
                              game['image'].toString().replaceAll(
                                    "http://semiz.fun:8080",
                                    "https://sea-turtle-app-qpyzd.ondigitalocean.app",
                                  );
                          final String nextDrawDate = game['nextDrawDate'];
                          return Stack(
                            children: [
                              Container(
                                height: 212,
                                margin: const EdgeInsets.all(16),
                                child: Image.network(
                                  image.toString(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Positioned(
                                bottom: 48, // Adjust the position as needed
                                left: 0, // Set left to 0
                                right: 0, // Set right to 0
                                child: Center(
                                  child: Text(
                                    prize,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
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
                        children: indicators(gameList.length, activePageTop)),
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
                        itemCount: gameList.length,
                        pageSnapping: true,
                        controller: _pageControllerBottom,
                        onPageChanged: (page) {
                          setState(() {
                            activePageBottom = page;
                          });
                        },
                        itemBuilder: (context, pagePosition) {
                          final game = gameList[pagePosition];
                          final dynamic prize = game['prize'].toString();
                          final dynamic image =
                              game['image'].toString().replaceAll(
                                    "http://semiz.fun:8080",
                                    "https://sea-turtle-app-qpyzd.ondigitalocean.app",
                                  );
                          final dynamic createdAt =
                              game['createdAt'].toString();
                          return Stack(
                            children: [
                              Container(
                                height: 212,
                                margin: const EdgeInsets.all(16),
                                child: Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 24,
                                right: 24, // Adjust the position as needed
                                child: Text(
                                  createdAt,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 48, // Adjust the position as needed
                                left: 0, // Set left to 0
                                right: 0, // Set right to 0
                                child: Center(
                                  child: Text(
                                    prize,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const Positioned(
                                  bottom: 20, // Adjust the position as needed
                                  left: 36, // Adjust the position as needed
                                  child: Center(
                                    child: Text(
                                      '30-36-23-33-44-55',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                  )),
                            ],
                          );
                        },
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            indicators(gameList.length, activePageBottom)),
                  ],
                )
              ],
            )),
      ],
    );
  }

  Widget resultsPage() {
    return Stack(
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
      ],
    );
  }

  Widget profilePage() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
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
                child: Image.asset(
                  'assets/images/profilecircle.png',
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(top: 48.0),
                            child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () async {},
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  minimumSize: const Size(96, 60),
                                ),
                                child: const Text(
                                  '10.000 cr',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {},
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF5C5C5C),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  minimumSize: const Size(96, 60),
                                ),
                                child: const Text(
                                  '50.000 cr',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {},
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF5C5C5C),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  minimumSize: const Size(96, 60),
                                ),
                                child: const Text(
                                  '100.000 cr',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ])),
                        Container(
                        margin: const EdgeInsets.only(top: 48.0),
                        child: TextButton(
                          onPressed: () async {},
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            minimumSize: const Size(320, 60),
                          ),
                          child: const Text(
                            'Install Credit',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        )),
                      ]),
                  Container(
                    margin: const EdgeInsets.only(top: 72.0),
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text('Edit Profile',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16,
                              ))),
                      Container(
                          margin: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'name: CAN',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'surname: CAN',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'email: mahmutcansevin@yahoo.com',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'phoneNumber: 342243234',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'city: İstanbul',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'brithday: 15/03/1994',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )),
                    ],
                  ))
                ],
              )),
        ],
      ),
    );
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
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
        resizeToAvoidBottomInset: false,
        body: Center(
          child: selectedIndex == 0
              ? mainPage()
              : selectedIndex == 1
                  ? resultsPage()
                  : profilePage(),
        ));
  }
}
