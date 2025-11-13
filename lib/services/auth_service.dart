// services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // جلب ID المستخدم الحالي
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // التحقق إذا كان المستخدم مسجل الدخول
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // جلب بيانات المستخدم
  User? get currentUser => _supabase.auth.currentUser;
}