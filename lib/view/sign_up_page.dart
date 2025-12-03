import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/style/colors.dart';
import '../../controllers/signup_controller.dart';
import '../services/profile_hive_services.dart';
import '../main.dart';
import '../../core/widgets/page_header.dart';

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
            // ===== Header ثابت =====
            Obx(() => PageHeader(
              title: controller.isAccountCreated.value
                  ? 'أكمل بياناتك'
                  : 'إنشاء حساب',
            )),
            const SizedBox(height: 10),
            // ===== Content =====
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isLargeScreen = constraints.maxWidth > 600;

                  if (isLargeScreen) {
                    // شاشة كبيرة → عرض النموذجين جنب بعض
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _stepCompleteProfile()),
                          const SizedBox(width: 30),
                          Expanded(child: _stepCreateAccount()),


                        ],
                      ),
                    );
                  } else {
                    // شاشة صغيرة → PageView خطوة بخطوة
                    return PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _stepCreateAccount(),
                        _stepCompleteProfile(),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 1: إنشاء الحساب =====
  Widget _stepCreateAccount() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _textField(
              label: "الإيميل",
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => controller.model.email = v,
            ),
            _textField(
              label: "كلمة السر",
              obscure: true,
              onChanged: (v) => controller.model.password = v,
            ),
            const SizedBox(height: 30),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : _primaryButton(
              text: "إنشاء الحساب",
              onPressed: () async {
                if (controller.model.email.isEmpty ||
                    controller.model.password.isEmpty) {
                  Get.snackbar("خطأ", "يرجى ملء جميع الحقول");
                  return;
                }

                await controller.registerAccount();

                if (controller.isAccountCreated.value &&
                    pageController.hasClients) {
                  pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  // ===== STEP 2: إكمال البيانات =====
  Widget _stepCompleteProfile() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _textField(
              label: "الاسم",
              onChanged: (v) => controller.model.name = v,
            ),
            _textField(
              label: "العنوان",
              onChanged: (v) => controller.model.address = v,
            ),
            _textField(
              label: "اسم الشركة",
              onChanged: (v) => controller.model.company = v,
            ),
            const SizedBox(height: 30),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : _primaryButton(
              text: "حفظ البيانات",
              onPressed: () async {
                if (controller.model.name.isEmpty) {
                  Get.snackbar("خطأ", "يرجى ملء جميع البيانات");
                  return;
                }

                // ⚠️ إضافة رسالة تأكيد قبل الحفظ
                bool confirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("تأكيد"),
                    content: const Text("هل تريد حفظ البيانات؟"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("إلغاء"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await controller.saveProfile();
                }
              },
            )),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                if (pageController.hasClients) {
                  pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                "العودة",
                style: TextStyle(color: AppColor.primary_color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Text Field =====
  Widget _textField({
    required String label,
    bool obscure = false,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        obscureText: obscure,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColor.gray, fontSize: 15),
          filled: true,
          fillColor: AppColor.gray.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // ===== Primary Button =====
  Widget _primaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary_color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
