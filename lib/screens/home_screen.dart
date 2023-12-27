import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:lotto_flutter/screens/game_screen.dart';
import 'package:lotto_flutter/screens/profile_edit_screen.dart';

import '../constants.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen(this.token, {Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class City {
  final String id;
  final String name;

  City(this.id, this.name);
}

String _addLeadingZero(int value) {
  return value < 10 ? '0$value' : '$value';
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger logger = Logger();
  List<City> cityList = [];
  List<Map<String, dynamic>> gameList = [];
  List<Map<String, dynamic>> userTicketsList = [];
  List<Map<String, dynamic>> recentDrawsList = [];
  List<dynamic> checkTicketList = [];
  int selectedIndex = 0;
  late PageController _pageControllerTop =
      PageController(viewportFraction: 0.8, initialPage: 0);
  late PageController _pageControllerBottom =
      PageController(viewportFraction: 0.8, initialPage: 0);
  int activePageTop = 0;
  int activePageBottom = 0;
  int addBalance = 10000;
  int balanceInfo = 0;
  String? ticketNum = '';
  List<bool> balanceButton = [true, false, false];

  final TextEditingController _registerController = TextEditingController();
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
    final data = responseBody['data']; // Set your error message here

    if (success) {
      profileInfo = data;
    } else {
      // Handle the error
      print('Failed to fetch profile: $responseBody');
    }
  }

  Future<void> checkUserTickets() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$mainUrl/api/v1/tickets'),
        headers: <String, String>{
          'Authorization': "Bearer ${widget.token}",
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);
      final bool success = responseBody['success'] ?? false;

      if (success) {
        print('User tickets fetched successfully.');
        final List<dynamic> tickets =
            (responseBody['data']['tickets'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
        userTicketsList = [...tickets];
      } else {
        // Handle the error
        final String errorMessage = responseBody['message'] ?? 'Unknown error';
        print('Failed to fetch user tickets: $errorMessage');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error fetching user tickets: $error');
    }
  }

  Future<void> getRecentDraws() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$mainUrl/api/v1/draws/recents'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);
      final bool success = responseBody['success'] ?? false;

      if (success) {
        print('Recent draws fetched successfully.');
        final List<dynamic> draws = (responseBody['draws'] as List<dynamic>);
        recentDrawsList = [...draws];
        print('recentDrawsList: $recentDrawsList');
      } else {
        // Handle the error
        final String errorMessage = responseBody['message'] ?? 'Unknown error';
        print('Failed to fetch user tickets: $errorMessage');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error fetching user tickets: $error');
    }
  }

  Future<void> checkTicket({String? ticketNumber}) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$mainUrl/api/v1/tickets/$ticketNumber'),
        headers: <String, String>{
          'Authorization': "Bearer ${widget.token}",
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);
      final bool success = responseBody['success'] ?? false;
      ticketNum = ticketNumber;

      if (success) {
        print('Ticket details fetched successfully.');

        checkTicketList.add(responseBody['game'] ?? '');
        checkTicketList.add(responseBody['prize'] ?? 0.0);
        checkTicketList.add(responseBody['guessedNumbers'] ?? 0);
        checkTicketList.add(responseBody['ticketCode'] ?? '');
        checkTicketList.add(responseBody['currency'] ?? '');
      } else {
        // Handle the error
        final String errorMessage = responseBody['message'] ?? 'Unknown error';
        print('Failed to fetch ticket details: $errorMessage');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error fetching ticket details: $error');
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

  Future<void> installBalance() async {
    final response = await http.post(
      Uri.parse('$mainUrl/api/v1/balance/add'),
      headers: <String, String>{
        'Authorization': "Bearer ${widget.token}",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, int>{
        'amount': addBalance,
      }),
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final success =
        responseBody['success'] as bool; // Set your error message here

    if (success) {
      getBalanceInfo();
      addBalance = 0;
    } else {
      // Handle the error
      print('Failed to fetch profile: $responseBody');
    }
  }

  Future<void> getCities() async {
    String url = "$mainUrl/api/v1/cities";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> cityData = responseData['data'];

      List<City> cities = cityData.map((city) {
        return City(city['_id'], city['name']);
      }).toList();

      setState(() {
        cityList = cities;
      });
    } else {
      throw Exception('Failed to load city data');
    }
  }

  String findCityNameById(String id) {
    try {
      City city = cityList.firstWhere((city) => city.id == id);
      return city.name;
    } catch (e) {
      return 'City not found';
    }
  }

  @override
  void initState() {
    getAllGames();
    getRecentDraws();
    getCities();
    getProfileInfo();
    getBalanceInfo();
    checkUserTickets();
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
                          DateTime dateTime =
                              DateTime.parse(game['nextDrawDate'].toString());
                          String nextDrawDate =
                              "${dateTime.year}-${_addLeadingZero(dateTime.month)}-${_addLeadingZero(dateTime.day)}";
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => GameScreen(
                                          token: widget.token,
                                          game: game['_id'] ?? ''),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 212,
                                  margin: const EdgeInsets.all(16),
                                  child: Image.network(
                                    image.toString(),
                                    fit: BoxFit.fill,
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
                              Positioned(
                                bottom: 20, // Adjust the position as needed
                                left: 24, // Adjust the position as needed
                                child: Text(
                                  'remains $nextDrawDate',
                                  style: const TextStyle(
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
                        itemCount: recentDrawsList.length,
                        pageSnapping: true,
                        controller: _pageControllerBottom,
                        onPageChanged: (page) {
                          setState(() {
                            activePageBottom = page;
                          });
                        },
                        itemBuilder: (context, pagePosition) {
                          final game = recentDrawsList[pagePosition];
                          final dynamic gameInside = game['game'];
                          final dynamic prize = gameInside['prize'].toString();
                          final dynamic numbers = game['numbers'].toString();
                          final dynamic image =
                            gameInside['image'].toString().replaceAll(
                                    "http://semiz.fun:8080",
                                    "https://sea-turtle-app-qpyzd.ondigitalocean.app",
                                  );
                          DateTime dateTime =
                              DateTime.parse(game['createdAt'].toString());
                          String lastDrawDate =
                              "${dateTime.year}-${_addLeadingZero(dateTime.month)}-${_addLeadingZero(dateTime.day)}";
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
                                  lastDrawDate,
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
                                    '$prize',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 20, // Adjust the position as needed
                                  left: 36, // Adjust the position as needed
                                  child: Center(
                                    child: Text(
                                      '$numbers',
                                      style: const TextStyle(
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
                            indicators(recentDrawsList.length, activePageBottom)),
                  ],
                )
              ],
            )),
      ],
    );
  }

  Widget resultsPage() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
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
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 160.0, right: 48.0, left: 48.0, bottom: 48.0),
              child: TextFormField(
                controller: _registerController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Check winning status of your ticket',
                  labelStyle: TextStyle(
                      color: Color(0xFF5C5C5C),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                  alignLabelWithHint: true,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                minimumSize: const Size(160, 60),
              ),
              onPressed: () async {
                final String registerTicket = _registerController.text;
                if ([registerTicket].every((field) => field.isNotEmpty)) {
                  checkTicketList = [];
                  await checkTicket(ticketNumber: registerTicket);
                } else {
                  const errorMessage =
                      "Ticket field must be filled"; // Set your error message here
                  showErrorMessage(context, errorMessage);
                }
              },
              child: const Text(
                'Check',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 20),
              ),
            ),
            const Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: Text(
                  'Your Tickets',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 20),
                )),
            const Padding(
                padding: EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    SizedBox(width: 32.0), // Adjust the spacing value as needed
                    Text(
                      'Numbers',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    SizedBox(width: 32.0), // Adjust the spacing value as needed
                    Text(
                      'Result',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 20),
                    )
                  ],
                )),
            SizedBox(
              height: 200,
              child: Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(userTicketsList.length, (index) {
                      final ticket = userTicketsList[index];
                      DateTime createdAt =
                          DateTime.parse(ticket['createdAt'].toString());
                      final bool hasDrawn = ticket['hasDrawn'];
                      final List<dynamic> blocks = ticket['blocks'];
                      final List<int> numbers = blocks.isNotEmpty
                          ? blocks[0]['numbers'].cast<int>()
                          : [];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${createdAt.year}/${_addLeadingZero(createdAt.month)}/${_addLeadingZero(createdAt.day)}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Text(
                              numbers.toString(),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Container(
                              width: 95.0,
                              height: 30.0,
                              color: !hasDrawn
                                  ? Colors.transparent
                                  : blocks[3]
                                      ? Colors.green
                                      : Colors.red,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  !hasDrawn
                                      ? 'Remains: xxx'
                                      : blocks[3]
                                          ? 'Prize: 100.000'
                                          : 'Lost',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget resultsDetailPage() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
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
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
                padding: const EdgeInsets.only(top: 160.0),
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          checkTicketList.isNotEmpty
                              ? "Hit ${checkTicketList[2]} number"
                              : "",
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 24),
                        )),
                    Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          checkTicketList.isNotEmpty
                              ? (checkTicketList[2] >= 3
                                  ? 'You earn'
                                  : 'You lose')
                              : "",
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: checkTicketList.isNotEmpty
                                  ? (checkTicketList[2] >= 3
                                      ? Colors.green
                                      : Colors.red)
                                  : Colors.transparent,
                              fontSize: 24),
                        )),
                    Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          checkTicketList.isNotEmpty
                              ? '${checkTicketList[1]}\$'
                              : '',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 40),
                        )),
                    const Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: Text(
                          'Wanna check again?',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 18),
                        )),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: TextFormField(
                controller: _registerController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Check winning status of your ticket',
                  labelStyle: TextStyle(
                      color: Color(0xFF5C5C5C),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                  alignLabelWithHint: true,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                minimumSize: const Size(160, 60),
              ),
              onPressed: () async {
                final String registerTicket = _registerController.text;
                if ([registerTicket].every((field) => field.isNotEmpty)) {
                  await checkTicket(ticketNumber: registerTicket);
                } else {
                  const errorMessage =
                      "Ticket field must be filled"; // Set your error message here
                  showErrorMessage(context, errorMessage);
                }
              },
              child: const Text(
                'Check',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 20),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget profilePage() {
    DateTime profileInfoBirthDate =
        DateTime.parse(profileInfo['birthDate'].toString());
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
          Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(top: 48.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        addBalance = 10000;
                                        balanceButton = [true, false, false];
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: balanceButton[0]
                                          ? Colors.deepPurpleAccent
                                          : const Color(0xFF5C5C5C),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
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
                                    onPressed: () {
                                      setState(() {
                                        addBalance = 50000;
                                        balanceButton = [false, true, false];
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: balanceButton[1]
                                          ? Colors.deepPurpleAccent
                                          : const Color(0xFF5C5C5C),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
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
                                    onPressed: () {
                                      setState(() {
                                        addBalance = 100000;
                                        balanceButton = [false, false, true];
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: balanceButton[2]
                                          ? Colors.deepPurpleAccent
                                          : const Color(0xFF5C5C5C),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
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
                              onPressed: () async {
                                installBalance();
                              },
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) => ProfileEditScreen(
                                            profileInfo: profileInfo,
                                            token: widget.token)));
                              },
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'name:${profileInfo['name']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                          Container(
                              margin: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'lastname:${profileInfo['lastName']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                          Container(
                              margin: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'email:${profileInfo['email']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                          Container(
                              margin: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'phoneNumber:${profileInfo['phoneNumber']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                          Container(
                              margin: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'city:${findCityNameById(profileInfo['cityId'])}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                          Container(
                              margin: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'birthDay: ${profileInfoBirthDate.year}-${_addLeadingZero(profileInfoBirthDate.month)}-${_addLeadingZero(profileInfoBirthDate.day)}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.only(top: 24.0),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (_) => LoginScreen()
                          ));
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8)),
                          ),
                          minimumSize: const Size(320, 60),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      )),
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
                  ? checkTicketList.isNotEmpty
                      ? resultsDetailPage()
                      : resultsPage()
                  : profilePage(),
        ));
  }
}
