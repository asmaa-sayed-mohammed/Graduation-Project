import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/main.dart';
import 'package:graduation_project/view/sign_up_page.dart';
import 'package:graduation_project/view/start_screen.dart';
import 'package:graduation_project/view/homescreen.dart';
import 'package:graduation_project/view/profile_screen.dart';
import 'package:graduation_project/view/reading_screen.dart';
import '../core/style/colors.dart';
import '../services/auth_service.dart';
import '../services/profile_services.dart';
import '../models/profile_model_supabase.dart';
import 'budget_screen.dart';
import 'main_screen.dart';
import '../core/widgets/page_header.dart';

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
      Get.off((() => MainScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تسجيل الدخول')),
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        textDirection: TextDirection.rtl, // القراءة من اليمين لليسار
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // PageHeader بدون أي padding أو margin إضافي
              PageHeader(
                title: "تسجيل الدخول",
                subtitle: null,
                leading: null,
              ),
              const SizedBox(height: 30), // مسافة بين الهيدر والحقول

              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: _buildRowField(
                    label: 'الإيميل',
                    controller: emailController,
                    hint: 'email@gmail.com'),
              ),

              // Password Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: _buildRowField(
                    label: 'كلمة السر',
                    controller: passwordController,
                    hint: "كلمة السر لا تقل عن 6 حروف",
                    obscureText: true),
              ),

              const SizedBox(height: 40),

              // Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary_color,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => _logIn(context),
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
                      padding: EdgeInsets.zero, // إزالة المسافات الزائدة
                      minimumSize: Size(50, 30), // الحجم الأدنى
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // لتصغير الـ touch area
                    ),
                    child: Text(
                      "أنشئ حساب",
                      style: TextStyle(
                        color: AppColor.primary_color, // اللون الرئيسي
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}
