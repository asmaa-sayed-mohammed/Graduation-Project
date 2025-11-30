import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/controllers/reading_controller.dart';
import 'package:graduation_project/view/start_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/widgets/page_header.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ReadingController controller = Get.put(ReadingController());

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      controller.loadLastReading(user.id); // تحميل آخر قراءة تلقائيًا
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===================== HEADER =====================
              const PageHeader(title: "إدخال القراءة"),
              const SizedBox(height: 30),

              // ===================== INPUT OLD READING =====================
              _buildReadingInput(
                label: 'القراءة القديمة',
                controller: controller.oldReadingController,
                onMicPressed: () =>
                    controller.recognizeVoice(controller.oldReadingController),
                onCameraPressed: () => controller.pickImage(
                  ImageSource.camera,
                  controller.oldReadingController,
                ),
                onGalleryPressed: () => controller.pickImage(
                  ImageSource.gallery,
                  controller.oldReadingController,
                ),
              ),

              // ===================== INPUT NEW READING =====================
              _buildReadingInput(
                label: 'القراءة الجديدة',
                controller: controller.newReadingController,
                onMicPressed: () =>
                    controller.recognizeVoice(controller.newReadingController),
                onCameraPressed: () => controller.pickImage(
                  ImageSource.camera,
                  controller.newReadingController,
                ),
                onGalleryPressed: () => controller.pickImage(
                  ImageSource.gallery,
                  controller.newReadingController,
                ),
              ),

              const SizedBox(height: 35),

              // ===================== BUTTON =====================
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                onPressed: () async {
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
                    // استخدام UUID الحقيقي من Supabase Auth
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      await controller.saveReadingToSupabase(userId: user.id);

                      final usage = result['consumption'];
                      final price = result['totalPrice'];
                      Get.off(
                        () => StartScreen(),
                        arguments: {'usage': usage, 'price': price},
                      );
                    } else {
                      Get.snackbar(
                        'خطأ',
                        'المستخدم غير مسجل الدخول',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
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

  Widget _buildReadingInput({
    required String label,
    required TextEditingController controller,
    required VoidCallback onMicPressed,
    required VoidCallback onCameraPressed,
    required VoidCallback onGalleryPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'ادخل القراءة',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: AppColor.black, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: onMicPressed,
                  icon: const Icon(Icons.mic),
                ),
                IconButton(
                  onPressed: onCameraPressed,
                  icon: const Icon(Icons.camera_alt),
                ),
                IconButton(
                  onPressed: onGalleryPressed,
                  icon: const Icon(Icons.upload_file),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
