import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/main_screen.dart';

import '../core/style/colors.dart';

class SignUpPage extends StatelessWidget {
   SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child:SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColor.primary_color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(120),
                  bottomRight: Radius.circular(120),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'انشيء حساب',
                    style: TextStyle(
                      color: AppColor.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 50,),

            //email-password-name

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary_color,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                // controller.processInput();
                Get.off(()=> MainScreen());
              },
              child: Text(
                ' تسجيل',
                style: TextStyle(
                  color: AppColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ),
          ],
        ),
      )

      ),
    );
  }
}
