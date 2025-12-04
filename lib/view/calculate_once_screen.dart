import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/calculation_result_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/controllers/reading_controller.dart';
import 'package:graduation_project/core/style/colors.dart';
import '../../core/widgets/page_header.dart';

// 💡 تم تحديث الاستيراد لصفحة الكهرباء الجديدة
import 'package:graduation_project/view/company_screen.dart';
import 'package:graduation_project/models/manual_calculation_result.dart';

class CalculateOnceScreen extends StatelessWidget {
  final controller = Get.put(ReadingController());

  CalculateOnceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ------------------- HEADER -------------------
              const PageHeader(title: "إدخال القراءة"),
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
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
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
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
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
                  // تحويل النصوص لقيم رقمية
                  double oldReading =
                      double.tryParse(controller.oldReadingController.text) ??
                      0.0;
                  double newReading =
                      double.tryParse(controller.newReadingController.text) ??
                      0.0;

                  // استدعاء الكلاس الجديد
                  final ManualCalculationResult result = controller
                      .calculateManualResult();

                  if (result.hasError) {
                    Get.snackbar(
                      'خطأ',
                      result.message ?? 'حدث خطأ غير معروف',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 4),
                    );
                  } else {
                    Get.to(
                      () => CalculationResultScreen(
                        oldReading: oldReading,
                        newReading: newReading,
                        consumption: result.consumption,
                        totalPrice: result.totalPrice,
                        tier: result.chip.toString(),
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

              // ------------------- LOCATION BUTTON (الموقع الجديد) -------------------
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
                  Get.to(() => CompanyScreen());
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: AppColor.black),
                    const SizedBox(width: 8),
                    Text(
                      'الموقع',
                      style: TextStyle(
                        color: AppColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
