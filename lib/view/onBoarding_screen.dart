import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:get/get.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/view/homescreen.dart';

class OnBoardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: OnBoardingSlider(
          controllerColor: AppColor.black,
          headerBackgroundColor: AppColor.white,
          pageBackgroundColor: AppColor.white2,

          finishButtonText: 'Login',
          finishButtonTextStyle:  TextStyle(
            color: AppColor.white,
            fontWeight: FontWeight.bold,
          ),

          finishButtonStyle: FinishButtonStyle(
            backgroundColor: AppColor.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          skipTextButton: Text('Skip',
            style: TextStyle(color: AppColor.black, fontSize: 16),
          ),

          onFinish: () {
            Get.off(() => Homescreen());
          },

          background: [
            SizedBox.shrink(),
            SizedBox.shrink(),
            SizedBox.shrink(),
          ],

          totalPage: 3,
          speed: 1.8,

          pageBodies: [
            _buildFixedImage('assets/images/Onboarding1.jpg'),
            _buildFixedImage('assets/images/Onboarding2.jpg'),
            _buildFixedImage('assets/images/Onboarding3.png'),
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
