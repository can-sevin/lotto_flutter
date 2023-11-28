import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:lotto_flutter/screens/home_screen.dart';

import '../constants.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> profileInfo;
  final String token;

  const ProfileEditScreen({required this.profileInfo, required this.token, Key? key}) : super(key: key);

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
  List<City> cityList = [];
  //City? selectedCity;

  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final Logger logger = Logger();


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

      log('cities: $cityList');
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
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(widget.token)));
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

  @override
  void initState() {
    getCities();
    profileInfo = widget.profileInfo;
    //selectedCity = City(profileInfo['cityId'], findCityNameById(profileInfo['cityId']));
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
                    height: 49.0,
                    width: 320.0,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: profileInfo['email'] ?? 'Enter your email',
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
                  ),
                ),
                Container(
                  alignment: const Alignment(0.0, -0.8),
                  child: SizedBox(
                    height: 49.0,
                    width: 320.0,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: profileInfo['name'] ?? 'Enter your name',
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
                  ),
                ),
                Container(
                  alignment: const Alignment(0.0, -0.6),
                  child: SizedBox(
                    height: 49.0,
                    width: 320.0,
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: profileInfo['lastName'] ?? 'Enter your lastname',
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
                  ),
                ),
                Container(
                  alignment: const Alignment(0.0, -0.4),
                  child: SizedBox(
                    height: 49.0,
                    width: 320.0,
                    child: TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: profileInfo['phoneNumber'] ?? 'Enter your phonenumber',
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
                  ),
                ),
                /*Container(
                  alignment: const Alignment(0.0, -0.2),
                  child: SizedBox(
                    height: 60.0,
                    width: 320.0,
                    child: DropdownButtonFormField<City>(
                      value: selectedCity,
                      onChanged: (City? newValue) {
                        setState(() {
                          selectedCity = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: findCityNameById(profileInfo['cityId']),
                        labelStyle: const TextStyle(
                          color: Color(0xFF5C5C5C),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      items: cityList.map<DropdownMenuItem<City>>((City city) {
                        return DropdownMenuItem<City>(
                          value: city,
                          child: Text(city.name),
                        );
                      }).toList(),
                    ),
                  ),
                ),*/
                Container(
                  alignment: const Alignment(0.0, 0.0),
                  child: SizedBox(
                    height: 49.0,
                    width: 320.0,
                    child: TextFormField(
                      controller: _birthdayController, // Add this line to connect the controller
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: profileInfo['birthDate'] ?? 'Select your brithday',
                        labelStyle: const TextStyle(
                          color: Color(0xFF5C5C5C),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                  ),
                ),
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
                      final String email = _emailController.text;
                      final String name = _nameController.text;
                      final String lastName = _lastNameController.text;
                      final String phoneNumber = _phoneNumberController.text;
                      //final String city = selectedCity?.id ?? "";
                      final String birthDay = _birthdayController.text;
                      Map<String, String> nonEmptyFields = {};

                      if (email.isNotEmpty) nonEmptyFields['email'] = email;
                      if (name.isNotEmpty) nonEmptyFields['name'] = name;
                      if (lastName.isNotEmpty) nonEmptyFields['lastName'] = lastName;
                      if (phoneNumber.isNotEmpty) nonEmptyFields['phoneNumber'] = phoneNumber;
                      // if (city.isNotEmpty) nonEmptyFields['city'] = city;
                      if (birthDay.isNotEmpty) nonEmptyFields['birthDay'] = birthDay;

                      if (nonEmptyFields.isNotEmpty) {
                        await updateProfile(nonEmptyFields);
                      } else {
                        const errorMessage = "At least one field must be filled"; // Set your error message here
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