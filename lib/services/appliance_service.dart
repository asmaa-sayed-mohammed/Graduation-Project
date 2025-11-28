import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graduation_project/models/appliance_category_model.dart';
import 'package:graduation_project/models/appliance_model.dart';
import 'package:graduation_project/models/user_appliance_model.dart';
import 'package:graduation_project/models/energy_tip_model.dart';

class ApplianceService {
  final SupabaseClient _supabase = Supabase.instance.client;

   ApplianceService();

  Future<List<ApplianceCategory>> getCategories() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('appliance_categories')
          .select('id, name_ar, icon_name')
          .order('id');

      final List<ApplianceCategory> categories = response
          .map<ApplianceCategory>((Map<String, dynamic> json) => ApplianceCategory.fromJson(json))
          .toList(growable: false);

      return categories;
    } on PostgrestException catch (e) {
      throw Exception('فشل في تحميل الفئات: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('خطأ في تنسيق البيانات: ${e.message}');
    }
  }
  // في ApplianceService - تأكد من هذه الدالة:
  Future<List<UserAppliance>> getUserAppliances(String userId) async {
    try {
      final response = await _supabase
          .from('user_appliances')
          .select('''
          *,
          appliances (*)
        ''')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final userAppliances = response
          .map<UserAppliance>((json) => UserAppliance.fromJson(json))
          .toList();

      return userAppliances;
    } on PostgrestException catch (e) {
      throw Exception('فشل في تحميل أجهزة المستخدم: ${e.message}');
    }
  }
  Future<List<Appliance>> getAppliancesByCategory(int categoryId) async {
    try {
      print('🔍 جاري تحميل الأجهزة للفئة: $categoryId');

      final response = await _supabase
          .from('appliances')
          .select('*')
          .eq('category_id', categoryId)
          .order('name_ar');

      print('✅ تم تحميل ${response.length} جهاز');

      final appliances = response
          .map<Appliance>((json) => Appliance.fromJson(json))
          .toList();

      return appliances;
    } on PostgrestException catch (e) {
      print('❌ خطأ في Supabase: ${e.message}');
      throw Exception('فشل في تحميل الأجهزة: ${e.message}');
    } catch (e) {
      print('❌ خطأ غير متوقع: $e');
      rethrow;
    }
  }


  Future<List<EnergyTip>> getStaticTips() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('energy_tips')
          .select('''
          *,
          appliances (name_ar)
        ''')
          .order('priority', ascending: false)
          .order('id');

      final List<EnergyTip> allTips = response
          .map<EnergyTip>((Map<String, dynamic> json) => EnergyTip.fromJson(json))
          .toList(growable: false);

      final List<EnergyTip> staticTips = allTips
          .where((final EnergyTip tip) => tip.applianceId == null || tip.applianceId == 0)
          .toList(growable: false);

      return staticTips;
    } on PostgrestException catch (e) {
      throw Exception('فشل في تحميل النصائح العامة: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('خطأ في تنسيق البيانات: ${e.message}');
    }
  }

  Future<List<EnergyTip>> getEnergyTipsForUserAppliances() async {
    try {
      final String? userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        return const <EnergyTip>[];
      }

      final List<Map<String, dynamic>> userAppliancesResponse = await _supabase
          .from('user_appliances')
          .select('appliance_id')
          .eq('user_id', userId)
          .eq('is_active', true);

      if (userAppliancesResponse.isEmpty) {
        return const <EnergyTip>[];
      }

      final List<int> applianceIds = userAppliancesResponse
          .map<int>((final Map<String, dynamic> item) => _safeCastInt(item['appliance_id']))
          .toList(growable: false);

      final List<Map<String, dynamic>> response = await _supabase
          .from('energy_tips')
          .select('''
            *,
            appliances (name_ar)
          ''')
          .order('priority', ascending: false)
          .order('id');

      final List<EnergyTip> allTips = response
          .map<EnergyTip>((Map<String, dynamic> json) => EnergyTip.fromJson(json))
          .toList(growable: false);

      final List<EnergyTip> userTips = allTips
          .where((final EnergyTip tip) =>
      tip.applianceId != null && applianceIds.contains(tip.applianceId))
          .toList(growable: false);

      return userTips;
    } on PostgrestException catch (e) {
      throw Exception('فشل في تحميل النصائح المخصصة: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('خطأ في تنسيق البيانات: ${e.message}');
    }
  }

  String getCurrentUserId() {
    return _supabase.auth.currentUser?.id ?? '';
  }

  Future<void> saveUserAppliances(final List<UserAppliance> userAppliances) async {
    try {
      final String userId = getCurrentUserId();

      if (userId.isEmpty) {
        throw Exception('المستخدم غير مسجل دخول');
      }

      final List<Map<String, dynamic>> appliancesData = userAppliances
          .map<Map<String, dynamic>>((final UserAppliance userAppliance) => <String, dynamic>{
        'user_id': userId,
        'appliance_id': userAppliance.applianceId,
        'brand': userAppliance.brand,
        'model': userAppliance.model,
        'hours_per_day': userAppliance.hoursPerDay,
        'is_active': true,
      })
          .toList(growable: false);

      await _supabase.from('user_appliances').insert(appliancesData);
    } on PostgrestException catch (e) {
      throw Exception('فشل في حفظ الأجهزة: ${e.message}');
    }
  }

  Future<void> deleteUserAppliance(final int userApplianceId) async {
    try {
      await _supabase
          .from('user_appliances')
          .delete()
          .eq('id', userApplianceId);
    } on PostgrestException catch (e) {
      throw Exception('فشل في حذف الجهاز: ${e.message}');
    }
  }

  Future<void> updateUserAppliance(final UserAppliance userAppliance) async {
    try {
      await _supabase
          .from('user_appliances')
          .update(<String, dynamic>{
        'brand': userAppliance.brand,
        'model': userAppliance.model,
        'hours_per_day': userAppliance.hoursPerDay,
        'is_active': userAppliance.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userAppliance.id);
    } on PostgrestException catch (e) {
      throw Exception('فشل في تحديث الجهاز: ${e.message}');
    }
  }

  // دالة مساعدة محلية
  static int _safeCastInt(dynamic value) {
    if (value == null) throw const FormatException('القيمة لا يمكن أن تكون null');
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    throw FormatException('قيمة غير صالحة لرقم: $value');
  }


}