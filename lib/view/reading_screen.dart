import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/controllers/reading_controller.dart';

class ReadingScreen extends StatelessWidget {
  final controller = Get.put(ReadingController());

  ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
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

              // Old Reading Field
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
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
                    IconButton(
                      onPressed: () => controller.pickImage(
                        ImageSource.gallery,
                        controller.oldReadingController,
                      ),
                      icon: Icon(Icons.upload_file, color: AppColor.black),
                    ),
                  ],
                ),
              ),

              // New Reading Field
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
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
                    IconButton(
                      onPressed: () => controller.pickImage(
                        ImageSource.gallery,
                        controller.newReadingController,
                      ),
                      icon: Icon(Icons.upload_file, color: AppColor.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Calculate Button
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
                    Get.snackbar(
                      'خطأ',
                      result['message'],
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orangeAccent,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'تم الحساب',
                      'الاستهلاك: ${result['consumption']} kWh\nالسعر: ${result['totalPrice']} جنيه',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
