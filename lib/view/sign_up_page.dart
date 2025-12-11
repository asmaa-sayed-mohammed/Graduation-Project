import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/login_page.dart';
import '../../core/style/colors.dart';
import '../../controllers/signup_controller.dart';
import '../services/profile_hive_services.dart';
import '../main.dart';
import '../../core/widgets/page_header.dart';
import 'homescreen.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
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
                    bool isLargeScreen = constraints.maxWidth > 700;

                    if (isLargeScreen) {
                      // شاشة كبيرة → كاردين جنب بعض
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCard(_stepCompleteProfile())),
                            const SizedBox(width: 30),
                            Expanded(child: _buildCard(_stepCreateAccount())),
                          ],
                        ),
                      );
                    } else {
                      // شاشة موبايل → PageView
                      return PageView(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildCard(_stepCreateAccount()),
                          _buildCard(_stepCompleteProfile()),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⬜ كارد موحد الشكل
  Widget _buildCard(Widget child) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  // ===== STEP 1: إنشاء حساب =====
  Widget _stepCreateAccount() {
    return Column(
      children: [
        const SizedBox(height: 10),

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

        const SizedBox(height: 25),

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
    );
  }

  // ===== STEP 2: إكمال البيانات =====
  Widget _stepCompleteProfile() {
    return Column(
      children: [
        const SizedBox(height: 10),

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

        const SizedBox(height: 25),

        Obx(() => controller.isLoading.value
            ? const CircularProgressIndicator()
            : _primaryButton(
          text: "حفظ البيانات",
          onPressed: () async {
            if (controller.model.name.isEmpty) {
              Get.snackbar("خطأ", "يرجى ملء جميع البيانات");
              return;
            }

            bool confirmed = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("تأكيد"),
                content: const Text("هل تريد حفظ البيانات؟"),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(false),
                    child: const Text("إلغاء"),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(true),
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
    );
  }

  // ===== Text Field محسّن =====
  Widget _textField({
    required String label,
    bool obscure = false,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        obscureText: obscure,
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // ===== زر رئيسي محسّن =====
  Widget _primaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary_color,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
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
        ),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("لديك حساب بالفعل؟ "),
            TextButton(
              onPressed: () => Get.to(() => LoginPage()),
              child: Text(
                "تسجيل الدخول",
                style: TextStyle(
                  color: AppColor.primary_color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("أو "),
            TextButton(
              onPressed: () => Get.to(() => Homescreen()),
              child: Text(
                "الذهاب للصفحة الرئيسية",
                style: TextStyle(
                  color: AppColor.primary_color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );

  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
