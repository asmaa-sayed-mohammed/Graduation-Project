import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/main.dart';
import 'package:graduation_project/services/auth_service.dart';
import 'package:graduation_project/view/homescreen.dart';
import 'package:graduation_project/view/login_page.dart';
import 'package:graduation_project/view/onBoarding_screen.dart';
import 'package:graduation_project/view/start_screen.dart';

import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textFadeIn;
  late Animation<double> _textFadeOut;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _textFadeIn = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _textFadeOut = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );
    _logoController.forward().then((_) {
      _textController.forward();
    });
    Timer(const Duration(milliseconds: 3500), () {
      final bool isOnboardingComplete = onboarding.get('isComplete') ?? false;
      final bool isLoggedIn = _authService.isLoggedIn();

      if (isLoggedIn) {
        Get.off(() => MainScreen());
      } else if (isOnboardingComplete) {
        Get.off(() => LoginPage());
      } else {
        Get.off(() => OnBoardingScreen());
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.primary_color,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoAnimation,
                child: Image.asset(
                  'assets/images/Splash_screen.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  double opacity = _textFadeIn.value * (1 - _textFadeOut.value);
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: Text(
                  "Electricity",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}