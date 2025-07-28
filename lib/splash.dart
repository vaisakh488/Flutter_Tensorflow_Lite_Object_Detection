import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';
import 'package:hive/hive.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Box appBox;
  bool islogged = false;

  @override
  void initState() {
    super.initState();
    appBox = Hive.box('appBox');
    Timer(Duration(seconds: 2), () {
      bool islogged = appBox.get('isloggedin', defaultValue: false);

      if (islogged) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ObjectDetectionPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/logo.png', height: 150), // your logo
      ),
    );
  }
}
