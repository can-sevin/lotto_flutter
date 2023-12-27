import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:lotto_flutter/screens/home_screen.dart';
import 'package:lotto_flutter/screens/register_screen.dart';

import '../constants.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> profileInfo;
  final String token;

  const ProfileEditScreen(
      {required this.profileInfo, required this.token, Key? key})
      : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class City {
  final String id;
  final String name;

  City(this.id, this.name);
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late Map<String, dynamic> profileInfo;
  late DateTime birthDay;
  List<City> cityList = [];
  City? selectedCity;

  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final Logger logger = Logger();

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

  Future<void> updateProfile(Map<String, String> userInfo) async {
    String url = "$mainUrl/api/v1/profile/user";
    final response = await http.patch(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': "Bearer ${widget.token}",
      },
      body: userInfo,
    );
    if (response.statusCode == 200) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(widget.token)));
    } else {
      throw Exception('Failed updateProfile');
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

  void setCurrentCity() {
    if (profileInfo.containsKey('cityId')) {
      String cityId = profileInfo['cityId'];
      try {
        City city = cityList.firstWhere((city) => city.id == cityId);
        setState(() {
          selectedCity = city;
        });
      } catch (e) {
        // Handle exception if cityId not found
        print("City with id $cityId not found");
      }
    }
  }

  String _addLeadingZero(int value) {
    return value < 10 ? '0$value' : '$value';
  }

  @override
  void initState() {
    getCities();
    profileInfo = widget.profileInfo;
    setCurrentCity();
    birthDay = DateTime.parse(profileInfo['birthDate'].toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Form(
            child: Stack(
              children: [
                Container(
                    alignment: const Alignment(0.0, -0.8),
                    child: SizedBox(
                        height: 90.0,
                        width: 320.0,
                        child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const InputLabelDecoration(
                                  label: 'Name',
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: profileInfo['name'] ??
                                        'Enter your name',
                                    labelStyle: const TextStyle(
                                        color: Color(0xFF5C5C5C),
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                  ),
                                ),
                              ]),
                        ))),
                Container(
                    alignment: const Alignment(0.0, -0.55),
                    child: SizedBox(
                        height: 90.0,
                        width: 320.0,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const InputLabelDecoration(
                                label: 'Lastname',
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: profileInfo['lastName'] ??
                                      'Enter your lastname',
                                  labelStyle: const TextStyle(
                                      color: Color(0xFF5C5C5C),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))),
                Container(
                    alignment: const Alignment(0.0, -0.3),
                    child: SizedBox(
                        height: 90.0,
                        width: 320.0,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const InputLabelDecoration(
                                label: 'Phonenumber',
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                controller: _phoneNumberController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: profileInfo['phoneNumber'] ??
                                      'Enter your phonenumber',
                                  labelStyle: const TextStyle(
                                      color: Color(0xFF5C5C5C),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))),
                Container(
                  alignment: const Alignment(0.0, -0.05),
                  child: SizedBox(
                    height: 90.0,
                    width: 320.0,
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const InputLabelDecoration(
                          label: 'City',
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButtonFormField<City>(
                          value: selectedCity,
                          onChanged: (City? newValue) {
                            setState(() {
                              selectedCity = newValue;
                            });
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Select your city',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          items:
                              cityList.map<DropdownMenuItem<City>>((City city) {
                            return DropdownMenuItem<City>(
                              value: city,
                              child: Text(city.name),
                            );
                          }).toList(),
                        ),
                      ],
                    )),
                  ),
                ),
                Container(
                    alignment: const Alignment(0.0, 0.2),
                    child: SizedBox(
                        height: 90.0,
                        width: 320.0,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const InputLabelDecoration(
                                label: 'Your Birthday',
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                controller: _birthdayController,
                                // Add this line to connect the controller
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText:
                                      'Brithday: ${birthDay.year}-${_addLeadingZero(birthDay.month)}-${_addLeadingZero(birthDay.day)}',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF5C5C5C),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                ),
                                onTap: () async {
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime(2005),
                                  );
                                  if (selectedDate != null) {
                                    setState(() {
                                      _birthdayController.text =
                                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ))),
                Container(
                  alignment: const Alignment(0.0, 0.65),
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      minimumSize: const Size(320, 60),
                    ),
                    onPressed: () async {
                      final String name = _nameController.text;
                      final String lastName = _lastNameController.text;
                      final String phoneNumber = _phoneNumberController.text;
                      final String birthDay = _birthdayController.text;
                      Map<String, String> nonEmptyFields = {};

                      if (name.isNotEmpty) nonEmptyFields['name'] = name;
                      if (lastName.isNotEmpty)
                        nonEmptyFields['lastName'] = lastName;
                      if (phoneNumber.isNotEmpty)
                        nonEmptyFields['phoneNumber'] = phoneNumber;
                      if (birthDay.isNotEmpty)
                        nonEmptyFields['birthDate'] = birthDay;
                        nonEmptyFields['cityId'] = selectedCity!.id;
                      if (nonEmptyFields.isNotEmpty) {
                        await updateProfile(nonEmptyFields);
                      } else {
                        const errorMessage =
                            "At least one field must be filled"; // Set your error message here
                        showErrorMessage(context, errorMessage);
                      }
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ),
                ),
                Container(
                  alignment: const Alignment(0.0, 0.9),
                  child: Image.asset(
                    'assets/images/lotto_bottom_logo.png',
                    fit: BoxFit.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
