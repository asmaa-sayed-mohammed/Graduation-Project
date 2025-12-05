import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/history_controller.dart';
import 'package:graduation_project/controllers/start_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/controllers/reading_controller.dart';
import 'package:graduation_project/view/start_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/bottom_navbar_controller.dart';
import '../core/widgets/bottom_navbar.dart';
import '../core/widgets/page_header.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ReadingController controller = Get.put(ReadingController());
  final history = Get.find<HistoryController>();

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      controller.loadLastReading(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== PageHeader =====
                  const PageHeader(title: "إدخال القراءة"),

                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        _buildReadingInput(
                          label: "القراءة القديمة",
                          controller: controller.oldReadingController,
                          onMicPressed: () => controller.recognizeVoice(
                            controller.oldReadingController,
                          ),
                          onCameraPressed: () => controller.pickImage(
                            ImageSource.camera,
                            controller.oldReadingController,
                          ),
                          onGalleryPressed: () => controller.pickImage(
                            ImageSource.gallery,
                            controller.oldReadingController,
                          ),
                        ),

                        _buildReadingInput(
                          label: "القراءة الجديدة",
                          controller: controller.newReadingController,
                          onMicPressed: () => controller.recognizeVoice(
                            controller.newReadingController,
                          ),
                          onCameraPressed: () => controller.pickImage(
                            ImageSource.camera,
                            controller.newReadingController,
                          ),
                          onGalleryPressed: () => controller.pickImage(
                            ImageSource.gallery,
                            controller.newReadingController,
                          ),
                        ),

                        const SizedBox(height: 30),
                        Center(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(35),
                            onTap: () async {
                              final result = controller.calculateManualResult();
                            history.syncWithCloud();
                              if (result.hasError) {
                                Get.snackbar(
                                  'خطأ',
                                  result.errorMessage!,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orangeAccent,
                                  colorText: Colors.white,
                                );
                              } else {
                                final user =
                                    Supabase.instance.client.auth.currentUser;
                                if (user != null) {
                                  await controller.saveReadingToSupabase(
                                    userId: user.id,
                                  );

                                  //  هنا بنمسح القراءة الجديدة بعد ما اتحفظت
                                  controller.newReadingController.clear();

                                  //  تحديث بيانات الصفحة الرئيسية فورًا
                                  final home = Get.find<HomeController>();
                                  await home.fetchLatestTwoReadings();
                                  await home.fetchLatestPrice();
                                  await home.fetchMonthlyTotals();

                                  // تحديث القيم مباشرة
                                  home.manualUsage.value = result.consumption;
                                  home.manualPrice.value = result.totalPrice;

                                  //  الرجوع للصفحة الرئيسية مع الحفاظ على BottomNavBar
                                  final navController =
                                      Get.find<NavigationController>();
                                  navController.currentIndex.value = 0;
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 80,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.primary_color,
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                "احسب",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textDirection: TextDirection.rtl,
                    controller: controller,
                    keyboardType: TextInputType.number,
                    cursorColor: AppColor.primary_color,
                    decoration: InputDecoration(
                      hintText: "ادخل القراءة",
                      hintTextDirection: TextDirection.rtl,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),

                // icons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.black),
                      onPressed: onMicPressed,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.black),
                      onPressed: onCameraPressed,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.upload_rounded,
                        color: Colors.black,
                      ),
                      onPressed: onGalleryPressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
