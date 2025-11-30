// services/profile_service.dart

import 'package:graduation_project/main.dart';
import 'package:graduation_project/models/profile_model_hive.dart';
import 'package:graduation_project/services/profile_hive_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model_supabase.dart';

class ProfileService {
  final String _tableName = 'profile';

  // Hive Service للتخزين المحلي
  final ProfileHiveService _hive =
      ProfileHiveService(profileBox); // profileBox جاي من main.dart

  // create
  Future<bool> createProfile(ProfileModel profile) async {
    try {
      // أولاً: نحفظ في Supabase
      final response = await cloud.from(_tableName).insert(profile.toMap());

      if (response == null) return false;

      print("✅ Profile created in Supabase");

      // ثانياً: نحفظ نسخة في Hive
      final hiveProfile = ProfileHive(
        id: profile.id ?? '',
        name: profile.name,
        address: profile.address,
        companyName: profile.company_Name,
        createdAt: '',
      );

      await _hive.addProfile(hiveProfile);
      print("💾 Profile saved in Hive");

      return true;
    } catch (e) {
      print("❌ Error creating profile: $e");
      return false;
    }
  }

  // read
  Future<ProfileModel?> getProfile(String id) async {
    try {
      final data =
          await cloud.from(_tableName).select().eq('id', id).single();

      return ProfileModel.fromMap(data);
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }

  // update
  Future<bool> updateProfile(ProfileModel profile) async {
    try {
      // أولاً: تعدي update على Supabase
      final response = await cloud
          .from(_tableName)
          .update(profile.toMap())
          .eq('id', profile.id ?? '');

      if (response == null) return false;

      print("🔄 Profile updated in Supabase");

      // ثانياً: نحدّث النسخة المحلية في Hive
      final hiveProfile = ProfileHive(
        id: profile.id ?? '',
        name: profile.name,
        address: profile.address,
        company_Name: profile.company_Name,
        createdAt: '',
      );

      await _hive.addProfile(hiveProfile);
      print("💾 Profile updated in Hive");

      return true;
    } catch (e) {
      print('❌ Error updating profile: $e');
      return false;
    }
  }

  // delete
  Future<bool> deleteProfile(String id) async {
    try {
      final response =
          await cloud.from(_tableName).delete().eq('id', id);

      if (response == null) return false;

      print("🗑️ Profile deleted from Supabase");

      // حزف من Hive
      await profileBox.delete(id);
      print("🗑️ Profile deleted from Hive");

      return true;
    } catch (e) {
      print('❌ Error deleting profile: $e');
      return false;
    }
  }
}
