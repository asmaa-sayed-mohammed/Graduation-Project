import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/auth_service.dart';
import '../controllers/profile_controller.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';
import 'main_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final _authService = new AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 👇 عرض المحتوى: محدود للشاشات الكبيرة
            double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth * 1;

            return SizedBox(

              width: maxWidth,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PageHeader(title: "الملف الشخصي",
                      leading: IconButton(icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 26,), onPressed: ()=>Get.to(MainScreen()),),
                    ),
                    const SizedBox(height: 30),
                    Obx(() {
                      final profile = controller.profile.value;

                      if (profile == null) {
                        return const Text(
                          "لا توجد بيانات للعرض",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "تاريخ الإنشاء: ${profile.createdAt.toString().substring(0, 10)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildInfoCard("العنوان", profile.address ?? "لا يوجد"),
                          const SizedBox(height: 15),
                          _buildInfoCard("اسم الشركة", profile.companyName ?? "لا يوجد"),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () => _authService.logOut(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                ' تسجيل الخروج',
                                style: TextStyle(
                                  color: AppColor.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    }),
                  ],

                ),
              ),
            );
          },

        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );

  }
}
