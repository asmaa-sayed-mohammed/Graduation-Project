import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/auth_service.dart';
import '../controllers/profile_controller.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';


class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: "الملف الشخصي",
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
                onPressed: () => Get.back(),
              ),
            ),

            Expanded(
              child: Obx(() {
                final profile = controller.profile.value;
                if (controller.isLoading.value && profile == null) {
                  return  Center(child: CircularProgressIndicator(color: AppColor.primary_color,));
                }
                if (profile == null) {
                  return const Center(
                    child: Text(
                      "لا توجد بيانات للعرض",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [

                      const SizedBox(height: 30),

                      /// ———————————— Avatar ————————————
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: AppColor.primary_color.withOpacity(0.2),
                        child: Icon(Icons.person, size: 60, color: AppColor.primary_color),
                      ),

                      const SizedBox(height: 15),

                      /// ———————————— Name ————————————
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      /// ———————————— Created At ————————————
                      Text(
                        "عضو منذ: ${profile.createdAt.toString().substring(0, 10)}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// ———————————— Cards List ————————————
                      _buildInfoCard(
                        title: "العنوان",
                        value: profile.address ?? "لا يوجد",
                        icon: Icons.location_on_outlined,
                      ),

                      _buildInfoCard(
                        title: "اسم الشركة",
                        value: profile.companyName ?? "لا يوجد",
                        icon: Icons.business_outlined,
                      ),

                      _buildInfoCard(
                        title: "البريد الإلكتروني",
                        value: profile.name ?? "لا يوجد",
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 35),

                      /// ———————————— Logout Button ————————————
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: ElevatedButton(
                          onPressed: () => _authService.logOut(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 3,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'تسجيل الخروج',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// —————————————————————————
  /// Stylish Info Card
  /// —————————————————————————
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: AppColor.primary_color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
