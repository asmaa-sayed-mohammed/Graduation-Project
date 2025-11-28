import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/appliance_screen.dart';
import 'package:graduation_project/view/budget_screen.dart';
import 'package:graduation_project/view/home_screen.dart';
import 'package:graduation_project/view/homescreen.dart';
import 'package:graduation_project/view/reading_screen.dart';
import 'package:graduation_project/view/tips_screen.dart';
import '../core/style/colors.dart';
import '../services/auth_service.dart';
import '../services/profile_services.dart';
import '../models/profile_model.dart';
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
      Get.off((()=> MainScreen()));
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        textDirection: TextDirection.rtl, // القراءة من اليمين لليسار
        children: [
          SizedBox(
            width: 140,
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: AppColor.primary_color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(120),
                    bottomRight: Radius.circular(120),
                  ),
                ),
                child: Center(
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      color: AppColor.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Fields
              _buildRowField(
                  label: 'الإيميل:', controller: emailController, hint: 'email@gmail.com'),
              _buildRowField(
                  label: 'كلمة السر:', controller: passwordController, obscureText: true),

              const SizedBox(height: 30),

              // Signup Button
              ElevatedButton(
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
            ],
          ),
        ),
      ),
    );
  }
}
