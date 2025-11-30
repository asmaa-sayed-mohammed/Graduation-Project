import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:graduation_project/view/login_page.dart';
import 'package:graduation_project/view/sign_up_page.dart';

import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';
import 'calculate_once_screen.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const PageHeader(title: "الصفحة الرئيسية"),
            const SizedBox(height: 50,),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary_color,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      Get.off(() => SignUpPage());
                    },
                    child: Text(
                      'انشيء حساب',
                      style: TextStyle(
                        color: AppColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ),
                  const SizedBox(height: 50,),
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
                      Get.to(()=> CalculateOnceScreen());
                    },
                    child: Text(
                      ' احسب مرة واحدة',
                      style: TextStyle(
                        color: AppColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ),
                  const SizedBox(height: 50,),
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
                      Get.to(()=> LoginPage());
                    },
                    child: Text(
                      ' لديك حساب بالفعل',
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

          ],
        ),
      )),
      
    );
  }
}