import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/sign_up_page.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _logIn(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final loggedIn = await _authService.login(email, password);

    if (loggedIn) {
      Get.off(() => MainScreen());
    } else {
      await Get.defaultDialog(
        title: " خطأ في تسجيل الدخول",
        middleText: "يرجى التحقق من بريدك الإلكتروني و كلمة السر مرة اخرى.",
        barrierDismissible: false,
        textConfirm: "حسنا",
        onConfirm: () {
          Get.back();
        },
      );
    }
  }

  Widget _buildRowField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColor.primary_color,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.gray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                textAlign: TextAlign.right,
                style: TextStyle(color: AppColor.black),
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            constraints.maxWidth > 600 ? 500 : constraints.maxWidth * 1;
            return SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    const PageHeader(
                      title: "تسجيل الدخول",
                      subtitle: null,
                      leading: null,
                    ),
                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildRowField(
                          label: 'الإيميل',
                          controller: emailController,
                          hint: 'email@gmail.com'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildRowField(
                          label: 'كلمة السر',
                          controller: passwordController,
                          hint: "كلمة السر لا تقل عن 6 حروف",
                          obscureText: true),
                    ),
                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _logIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary_color,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'تسجيل',
                          style: TextStyle(
                            color: AppColor.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "  ليس لديك حساب؟ ",
                          style: TextStyle(
                            color: AppColor.black,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.to(() => SignUpPage()),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "أنشئ حساب",
                            style: TextStyle(
                              color: AppColor.primary_color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
