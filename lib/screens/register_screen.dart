import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:lotto_flutter/screens/otp_screen.dart';

import '../constants.dart';

class RegisterScreen extends StatefulWidget {
  final String email; // Declare email as an instance variable
  const RegisterScreen(this.email,{Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class City {
  final String id;
  final String name;

  City(this.id, this.name);
}

class InputLabelDecoration extends StatelessWidget {
  final String label;
  final TextStyle textStyle;

  const InputLabelDecoration({
    required this.label,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: textStyle,
      ),
    );
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  List<City> cityList = [];
  City? selectedCity;
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final Logger logger = Logger();

  Future<void> getOtpCode(BuildContext context, String email, String name, String lastName, String phoneNumber, String cityId, String birthDate) async {
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

    final errorMessage = responseBody['message'] as String; // Set your error message here
    final success = responseBody['success'] as bool; // Set your error message here
    final int? code = responseBody['code'];

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OtpScreen(email, requestScheme)),
      );
      showSendMessage(context, errorMessage);
    } else if ([2009, 2010, 2011, 2012, 2013, 2014].contains(code)) {
      showErrorMessage(context, errorMessage);
    } else {
      showErrorMessage(context, errorMessage);
    }
  }

  Future<void> getCities() async {
    // Replace your RESTful API here.
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

  @override
  void initState() {
    getCities();
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
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Enter your name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your lastname',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
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
                          label: 'Phone Number',
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your phone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
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
                          controller: _birthdayController, // Add this line to connect the controller
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Select birthday',
                            border: OutlineInputBorder(
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
                      ],
                    )),
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
                      final String email = widget.email;
                      final String name = _nameController.text;
                      final String lastName = _lastNameController.text;
                      final String phoneNumber = _phoneNumberController.text;
                      final String city = selectedCity?.id ?? "";
                      final String birthDay = _birthdayController.text;
                      if ([name, lastName, phoneNumber, city, birthDay].every((field) => field.isNotEmpty)) {
                        await getOtpCode(context, email, name, lastName, phoneNumber, city, birthDay);
                      } else {
                        const errorMessage = "All fields must be filled"; // Set your error message here
                        showErrorMessage(context, errorMessage);
                      }
                    },
                    child: const Text(
                      'Submit',
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