import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/onBoarding_screen.dart';
import 'package:graduation_project/view/reading_screen.dart';
import 'package:graduation_project/view/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}