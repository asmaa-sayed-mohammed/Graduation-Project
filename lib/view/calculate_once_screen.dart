import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/controllers/reading_controller.dart';

class CalculateOnceScreen extends StatelessWidget {

  final controller = Get.put(ReadingController());

  CalculateOnceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,

      // (Floating Action Button)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColor.primary_color,
        onPressed: () {
          // Add your onPressed code here!
        },
        icon: Icon(Icons.calculate, color: AppColor.black),
        label: Text(
          'الموقع',
          style: TextStyle(
            color: AppColor.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ----------------------------------------------------
              //                 HEADER
              // ----------------------------------------------------
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
                      'ادخل القراءة',
                      style: TextStyle(
                        color: AppColor.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ----------------------------------------------------
              //                 INPUT FIELD 1
              // ----------------------------------------------------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColor.gray),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        cursorColor: AppColor.black,
                        decoration: InputDecoration(
                          hintText: 'ادخل هنا كتابة او باستخدام الكاميرا او الميكروفون',
                          border: InputBorder.none,
                        ),
                        controller: controller.textController,
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.recognizeVoice,
                      icon: Icon(Icons.mic, color: AppColor.black),
                    ),
                    IconButton(
                      onPressed: () => controller.pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt, color: AppColor.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ----------------------------------------------------
              //                 INPUT FIELD 2
              // ----------------------------------------------------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColor.gray),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        cursorColor: AppColor.black,
                        decoration: InputDecoration(
                          hintText: 'ادخل هنا كتابة او باستخدام الكاميرا او الميكروفون',
                          border: InputBorder.none,
                        ),
                        controller: controller.textController,
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.recognizeVoice,
                      icon: Icon(Icons.mic, color: AppColor.black),
                    ),
                    IconButton(
                      onPressed: () => controller.pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt, color: AppColor.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
                    // calculate button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary_color,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        
                      },
                      child: Text(
                        'احسب',
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
