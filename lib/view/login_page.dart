import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/main.dart';
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
      Get.off(() => MainScreen());
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
        textDirection: TextDirection.rtl,
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
              const PageHeader(title: "تسجيل الدخول"),
              _buildRowField(
                  label: 'الإيميل:',
                  controller: emailController,
                  hint: 'email@gmail.com'),
              _buildRowField(
                label: 'كلمة السر:',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_color,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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