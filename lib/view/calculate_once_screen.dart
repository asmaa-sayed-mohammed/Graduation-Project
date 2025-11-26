import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/calculation_result_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/controllers/reading_controller.dart';
import 'package:graduation_project/core/style/colors.dart';

class CalculateOnceScreen extends StatelessWidget {
  final controller = Get.put(ReadingController());

  CalculateOnceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.primary_color,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.black),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: AppColor.primary_color,
      //   onPressed: () {
      //     // يمكنك إضافة أي وظيفة هنا إذا كنت تريد
      //   },
      //   icon: Icon(Icons.calculate, color: AppColor.black),
      //   label: Text(
      //     'الموقع',
      //     style: TextStyle(
      //       color: AppColor.black,
      //       fontSize: 18,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ------------------- HEADER -------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primary_color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(120),
                    bottomRight: Radius.circular(120),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      'ادخل القراءة',
                      style: TextStyle(
                        color: AppColor.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ------------------- OLD READING FIELD -------------------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                        controller: controller.oldReadingController,
                        decoration: InputDecoration(
                          hintText: 'ادخل القراءة القديمة',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: AppColor.black, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.recognizeVoice(
                        controller.oldReadingController,
                      ),
                      icon: Icon(Icons.mic, color: AppColor.black),
                    ),
                    IconButton(
                      onPressed: () => controller.pickImage(
                        ImageSource.camera,
                        controller.oldReadingController,
                      ),
                      icon: Icon(Icons.camera_alt, color: AppColor.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ------------------- NEW READING FIELD -------------------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                        controller: controller.newReadingController,
                        decoration: InputDecoration(
                          hintText: 'ادخل القراءة الجديدة',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: AppColor.black, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.recognizeVoice(
                        controller.newReadingController,
                      ),
                      icon: Icon(Icons.mic, color: AppColor.black),
                    ),
                    IconButton(
                      onPressed: () => controller.pickImage(
                        ImageSource.camera,
                        controller.newReadingController,
                      ),
                      icon: Icon(Icons.camera_alt, color: AppColor.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ------------------- CALCULATE BUTTON -------------------
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  final result = controller.calculateManualResult();

                  if (result['error'] == true) {
                    // لو في خطأ فقط نظهر Snackbar
                    Get.snackbar(
                      'خطأ',
                      result['message'],
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 4),
                    );
                  } else {
                    // لو مفيش خطأ نروح لصفحة النتيجة مباشرة
                    Get.to(
                      () => CalculationResultScreen(
                        oldReading: (result['oldReading'] as num).toDouble(),
                        newReading: (result['newReading'] as num).toDouble(),
                        consumption: (result['consumption'] as num).toDouble(),
                        totalPrice: (result['totalPrice'] as num).toDouble(),
                        tier: result['tier'].toString(), // مهم جداً
                      ),
                    );
                  }
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
              const SizedBox(height: 20),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // إضافة أي وظيفة للزرار هنا
                },
                icon: Icon(Icons.location_on, color: AppColor.black),
                label: Text(
                  'الموقع',
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
