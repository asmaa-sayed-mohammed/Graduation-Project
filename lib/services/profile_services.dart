// services/profile_service.dart
import 'package:flutter/src/material/snack_bar.dart';
import 'package:graduation_project/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model_supabase.dart';
import '../models/profile_model_supabase.dart';

class ProfileService {
  final String _tableName = 'profile';

  // create
  Future<bool> createProfile(ProfileModel profile) async {
    try {
      final response = await cloud.from(_tableName).insert(profile.toMap());

      if (response == null) {
        return false; // الإدخال فشل
      }

      return true;  // تم الإدخال بنجاح
    } catch (e) {
      print("Error creating profile: $e");
      return false;
    }
  }




  // read
  Future<ProfileModel?> getProfile(String id) async {
    try {
      final data = await cloud.from(_tableName).select().eq('id', id).single();
      return ProfileModel.fromMap(data);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  //update
  Future<bool> updateProfile(ProfileModel profile) async {
    try {
      final response = await cloud.from(_tableName)
          .update(profile.toMap())
          .eq('id', profile.id as Object);
      return response != null;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // delete
  Future<bool> deleteProfile(String id) async {
    try {
      final response = await cloud.from(_tableName).delete().eq('id', id);
      return response != null;
    } catch (e) {
      print('Error deleting profile: $e');
      return false;
    }
  }

}
