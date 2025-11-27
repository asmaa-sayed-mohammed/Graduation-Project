// services/auth_service.dart
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
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

}