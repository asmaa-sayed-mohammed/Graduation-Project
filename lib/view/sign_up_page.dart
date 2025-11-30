import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/style/colors.dart';
import '../../controllers/signup_controller.dart';
import '../services/profile_hive_services.dart';
import '../main.dart';
import '../../core/widgets/page_header.dart'; // استدعاء الـHeader

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final controller = Get.put(SignUpController(ProfileHiveService(profileBox)));
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header ثابت لكل الصفحات =====
            Obx(() => PageHeader(
              title: controller.isAccountCreated.value ? 'أكمل بياناتك' : 'إنشاء حساب',
            )),

            // ===== Content =====
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _stepCreateAccount(),
                  _stepCompleteProfile(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepCreateAccount() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _textField(
            label: "الإيميل",
            onChanged: (v) => controller.model.email = v,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _textField(
            label: "كلمة السر",
            obscure: true,
            onChanged: (v) => controller.model.password = v,
          ),
          const SizedBox(height: 30),
          Obx(() => controller.isLoading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: () async {
              if (controller.model.email.isEmpty || controller.model.password.isEmpty) {
                Get.snackbar("خطأ", "يرجى ملء جميع الحقول");
                return;
              }

              await controller.registerAccount();

              if (controller.isAccountCreated.value) {
                pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: const Text("إنشاء الحساب",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary_color,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _stepCompleteProfile() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _textField(
            label: "الاسم",
            onChanged: (v) => controller.model.name = v,
          ),
          const SizedBox(height: 16),
          _textField(
            label: "العنوان",
            onChanged: (v) => controller.model.address = v,
          ),
          const SizedBox(height: 16),
          _textField(
            label: "اسم الشركة",
            onChanged: (v) => controller.model.company = v,
          ),
          const SizedBox(height: 30),
          Obx(() => controller.isLoading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: () async {
              if (controller.model.name.isEmpty) {
                Get.snackbar("خطأ", "يرجى ملء جميع البيانات");
                return;
              }

              await controller.saveProfile();
            },
            child: const Text("حفظ البيانات",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary_color,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          )),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Text(
              "العودة",
              style: TextStyle(color: AppColor.primary_color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    bool obscure = false,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        obscureText: obscure,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: AppColor.gray.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
