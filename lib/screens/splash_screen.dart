import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotto_flutter/screens/home_screen.dart';
import 'package:lotto_flutter/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => LoginScreen()
      ));
    });
  }
  
  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: <Widget>[
         Container(
          decoration:  const BoxDecoration(
            image:  DecorationImage(image: AssetImage("assets/images/background.png"), fit: BoxFit.cover),
          ),
        ),
        Stack(
          children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container (
            margin: const EdgeInsets.all(24.0),
            child: Image.asset(
            'assets/images/looto_vertical.png',
            fit: BoxFit.none,
          ),)
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container (
            margin: const EdgeInsets.all(24.0),
            child: Image.asset(
            'assets/images/splash_text.png',
            fit: BoxFit.none,
          ),)
        ),
        ],
      ),],)
  );
  }
}
