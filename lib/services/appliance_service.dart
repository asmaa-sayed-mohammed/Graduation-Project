// services/appliance_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graduation_project/models/appliance_category_model.dart';
import 'package:graduation_project/models/appliance_model.dart';
import 'package:graduation_project/models/energy_tip_model.dart';

class ApplianceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ١. جلب جميع الفئات من Supabase
  Future<List<ApplianceCategory>> getCategories() async {
    try {
      final response = await _supabase
          .from('appliance_categories')
          .select('*')
          .order('name_ar');

      return response.map<ApplianceCategory>((json) =>
          ApplianceCategory.fromJson(json)).toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // ٢. جلب الأجهزة حسب الفئة
  Future<List<Appliance>> getAppliancesByCategory(int categoryId) async {
    try {
      final response = await _supabase
          .from('appliances')
          .select('*')
          .eq('category_id', categoryId)
          .order('name_ar');

      return response.map<Appliance>((json) =>
          Appliance.fromJson(json)).toList();
    } catch (e) {
      print('Error getting appliances by category: $e');
      return [];
    }
  }

  // ٣. جلب جميع الأجهزة
  Future<List<Appliance>> getAllAppliances() async {
    try {
      final response = await _supabase
          .from('appliances')
          .select('*')
          .order('name_ar');

      return response.map<Appliance>((json) =>
          Appliance.fromJson(json)).toList();
    } catch (e) {
      print('Error getting all appliances: $e');
      return [];
    }
  }

  // ٤. جلب جهاز محدد
  Future<Appliance?> getApplianceById(int applianceId) async {
    try {
      final response = await _supabase
          .from('appliances')
          .select('*')
          .eq('id', applianceId)
          .single();

      return Appliance.fromJson(response);
    } catch (e) {
      print('Error getting appliance: $e');
      return null;
    }
  }

  // ٥. جلب جميع النصائح
  Future<List<EnergyTip>> getAllEnergyTips() async {
    try {
      final response = await _supabase
          .from('energy_tips')
          .select('*, appliances(*)')
          .order('priority')
          .order('created_at', ascending: false);

      return response.map<EnergyTip>((json) =>
          EnergyTip.fromJson(json)).toList();
    } catch (e) {
      print('Error getting energy tips: $e');
      return [];
    }
  }

  // ٦. جلب نصائح حسب الجهاز
  Future<List<EnergyTip>> getEnergyTipsByAppliance(int applianceId) async {
    try {
      final response = await _supabase
          .from('energy_tips')
          .select('*, appliances(*)')
          .eq('appliance_id', applianceId)
          .order('priority')
          .order('created_at', ascending: false);

      return response.map<EnergyTip>((json) =>
          EnergyTip.fromJson(json)).toList();
    } catch (e) {
      print('Error getting energy tips by appliance: $e');
      return [];
    }
  }

  // ٧. جلب نصائح حسب الأولوية
  Future<List<EnergyTip>> getEnergyTipsByPriority(String priority) async {
    try {
      final response = await _supabase
          .from('energy_tips')
          .select('*, appliances(*)')
          .eq('priority', priority)
          .order('created_at', ascending: false);

      return response.map<EnergyTip>((json) =>
          EnergyTip.fromJson(json)).toList();
    } catch (e) {
      print('Error getting energy tips by priority: $e');
      return [];
    }
  }

  // ٨. البحث في الأجهزة
  Future<List<Appliance>> searchAppliances(String query) async {
    try {
      final response = await _supabase
          .from('appliances')
          .select('*')
          .or('name_ar.ilike.%$query%,name_en.ilike.%$query%')
          .order('name_ar');

      return response.map<Appliance>((json) =>
          Appliance.fromJson(json)).toList();
    } catch (e) {
      print('Error searching appliances: $e');
      return [];
    }
  }

  // ٩. جلب نصائح عشوائية للعرض في الشاشة الرئيسية
  Future<List<EnergyTip>> getRandomTips({int limit = 3}) async {
    try {
      final allTips = await getAllEnergyTips();
      allTips.shuffle();
      return allTips.take(limit).toList();
    } catch (e) {
      print('Error getting random tips: $e');
      return [];
    }
  }
}