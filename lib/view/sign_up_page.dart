import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/profile_hive_services.dart';
import 'package:graduation_project/view/homescreen.dart';
import '../core/style/colors.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/profile_services.dart';
import '../models/profile_model_supabase.dart';
import 'main_screen.dart';
import '../models/profile_model_hive.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final _profileService = ProfileService();

  final AuthService _authService = AuthService();
  final _profileHiveService = ProfileHiveService(profileBox);

  void _signUp(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final address = addressController.text.trim();
    final companyName = companyController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final user = await _authService.register(email, password);

    if (user != null) {
      final profile = ProfileModel(
        id: user.id,
        name: name,
        address: address,
        company_Name: companyName,
        created_at: DateTime.now(),
      );

      final hiveProfile = ProfileHive(id: user.id, name: name, createdAt: DateTime.now(), companyName: companyName, address: address);
      await _profileHiveService.addProfile(hiveProfile);

      final success = await _profileService.createProfile(profile);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Get.off(() => Homescreen());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create profile')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup failed!')),
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
                    'انشيء حساب',
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
              _buildRowField(label: 'الاسم:', controller: nameController, hint: 'اسمك'),
              _buildRowField(label: 'العنوان:', controller: addressController, hint: 'المدينة'),
              _buildRowField(label: 'اسم الشركة:', controller: companyController, hint: 'اختياري'),

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
                onPressed: () => _signUp(context),
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
