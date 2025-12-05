// services/auth_service.dart
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:graduation_project/view/homescreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // جلب ID المستخدم الحالي
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // التحقق إذا كان المستخدم مسجل الدخول
  bool isLoggedIn()=>cloud.auth.currentSession!=null;

  // جلب بيانات المستخدم
  User? get currentUser => _supabase.auth.currentUser;

  //create new account
  Future<User?> register(String email, String password) async {
    final response = await cloud.auth.signUp(
      email: email,
      password: password,
    );

    return response.user;
  }


  //login to account
  Future<bool> login(String email, String password) async {
    try {
      await cloud.auth.signInWithPassword(password: password, email: email);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // log out from account
  Future<bool> logOut() async {
    try {
      await cloud.auth.signOut();
      Get.off(()=>Homescreen());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String?> getUserId() async {
    try {
      final user = cloud.auth.currentUser;
      if (user == null) return null;

      final data = await cloud
          .from('profile')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) return null;
      return data['id'] as String?;
    } catch (e) {
      print('Error getting user id: $e');
      return null;
    }
  }


}