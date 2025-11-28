import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/profile_hive_services.dart';
import '../core/style/colors.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/profile_services.dart';
import '../models/profile_model_supabase.dart';
import 'main_screen.dart';
import '../models/profile_model_hive.dart';

final getProfiles = <ProfileHive>[].obs;

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState(){
    super.initState();
    loadProfile();
  }

  void loadProfile(){

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
                      'الملف الشخصي',
                       style: TextStyle(
                          color: AppColor.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ),
                const SizedBox(height: 40),

              ]
            ),
          ),
        ),
    );
  }
}
