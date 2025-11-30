import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:get/get.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/services/auth_service.dart';
import 'package:graduation_project/view/homescreen.dart';
import 'package:graduation_project/view/login_page.dart';
import 'package:graduation_project/view/start_screen.dart';

import '../main.dart';

class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({super.key});

  final _authService = AuthService();

  bool loggedIn() {
    final bool loggedIn = _authService.isLoggedIn();
    return loggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: OnBoardingSlider(
          controllerColor: AppColor.black,
          headerBackgroundColor: AppColor.white,
          pageBackgroundColor: AppColor.white2,
          finishButtonText: 'اذهب لصفحة التسجيل',
          finishButtonTextStyle: TextStyle(
            color: AppColor.white,
            fontWeight: FontWeight.bold,
          ),
          finishButtonStyle: FinishButtonStyle(
            backgroundColor: AppColor.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          skipTextButton: Text(
            'Skip',
            style: TextStyle(color: AppColor.black, fontSize: 16),
          ),
          onFinish: () {
            onboarding.put('isComplete', true);
            final logged = loggedIn();
            Get.off(() => logged ? StartScreen() : Homescreen());
          },
          background: [
            const SizedBox.shrink(),
            const SizedBox.shrink(),
            const SizedBox.shrink(),
          ],
          totalPage: 3,
          speed: 1.8,
          pageBodies: [
            _buildFixedImage('assets/images/On_boarding1.png'),
            _buildFixedImage('assets/images/On_boarding2.png'),
            _buildFixedImage('assets/images/On_boarding3.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedImage(String path) {
    return Center(
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}