import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/view/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/controllers/reading_controller.dart';

class ReadingScreen extends StatelessWidget {
  final controller = Get.put(ReadingController());

  ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===================== HEADER =====================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColor.primary_color,   // ← اللون الأساسي
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(70),
                    bottomRight: Radius.circular(70),
                  ),
                ),
                child: Column(
                  children: const [
                    SizedBox(height: 15),
                    Icon(Icons.bolt, size: 60, color: Colors.black),
                    SizedBox(height: 10),
                    Text(
                      'إدخال القراءة',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ===================== INPUT OLD READING =====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "القراءة القديمة",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
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
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(color: AppColor.black, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                controller.recognizeVoice(controller.oldReadingController),
                            icon: const Icon(Icons.mic),
                          ),
                          IconButton(
                            onPressed: () => controller.pickImage(
                              ImageSource.camera,
                              controller.oldReadingController,
                            ),
                            icon: const Icon(Icons.camera_alt),
                          ),
                          IconButton(
                            onPressed: () => controller.pickImage(
                              ImageSource.gallery,
                              controller.oldReadingController,
                            ),
                            icon: const Icon(Icons.upload_file),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===================== INPUT NEW READING =====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "القراءة الجديدة",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
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
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(color: AppColor.black, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                controller.recognizeVoice(controller.newReadingController),
                            icon: const Icon(Icons.mic),
                          ),
                          IconButton(
                            onPressed: () => controller.pickImage(
                              ImageSource.camera,
                              controller.newReadingController,
                            ),
                            icon: const Icon(Icons.camera_alt),
                          ),
                          IconButton(
                            onPressed: () => controller.pickImage(
                              ImageSource.gallery,
                              controller.newReadingController,
                            ),
                            icon: const Icon(Icons.upload_file),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // ===================== BUTTON =====================
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_color,
                  padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
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
                    final usage = result['consumption'];
                    final price = result['totalPrice'];

                    Get.off(
                      () => StartScreen(),
                      arguments: {'usage': usage, 'price': price},
                    );
                  }
                },
                child: const Text(
                  'احسب',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
