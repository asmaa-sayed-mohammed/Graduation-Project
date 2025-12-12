import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/core/widgets/page_header.dart';
import 'package:graduation_project/view/homescreen.dart';
import 'package:graduation_project/view/sign_up_page.dart';
import '../core/style/colors.dart';
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
        const SnackBar(content: Text('برجاء إدخال جميع البيانات')),
      );
      return;
    }

    final loggedIn = await _authService.login(email, password);

    if (loggedIn) {
      Get.off(() => MainScreen());
    } else if(!_authService.hasInternet.value){
      Get.defaultDialog(
        title: "خطأ",
        middleText: "يرجى التحقق من اتصالك بالنترنت",
        textConfirm: "حسنًا",
        onConfirm: () => Get.back(),
      );
    }else{
      Get.defaultDialog(
        title: "خطأ",
        middleText: "تحقق من صحة الإيميل و الباسورد الخاص بك",
        textConfirm: "حسنًا",
        onConfirm: () => Get.back(),
      );
    }
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(

          label,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppColor.primary_color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColor.primary_color),
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                PageHeader(title: 'تسجيل الدخول',),
                 const SizedBox(height: 30),

                // Card
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInput(
                          label: "الإيميل",
                          hint: "email@gmail.com",
                          icon: Icons.email_outlined,
                          controller: emailController,
                        ),

                        const SizedBox(height: 20),

                        _buildInput(
                          label: "كلمة السر",
                          hint: "********",
                          icon: Icons.lock_outline,
                          obscure: true,
                          controller: passwordController,
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _logIn(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary_color,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Signup + Home
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("ليس لديك حساب؟ "),
                    TextButton(
                      onPressed: () => Get.to(() => SignUpPage()),
                      child: Text(
                        "إنشاء حساب",
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
            ),
          ),
        ),
      ),
    );
  }
}
