import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appliance_model.dart';
import '../models/user_appliance_model.dart';

class ApplianceService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// جلب كل الأجهزة
  Future<List<Appliance>> getAllAppliances() async {
    final response = await supabase.from('appliances').select();

    return response
        .map((e) => Appliance.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// جلب أجهزة المستخدم
  Future<List<UserAppliance>> getUserAppliances(String userId) async {
    final res = await supabase
        .from('user_appliances')
        .select('*, appliances(*)') // تأكد من اسم الجدول الصحيح
        .eq('user_id', userId);

    return res.map((e) => UserAppliance.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// إضافة جهاز
  Future<void> addUserAppliance({
    required int applianceId,
    required double hoursPerDay,
    required int quantity,
    required String priority,
  }) async {
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('user_appliances').insert({
      'user_id': userId,
      'appliance_id': applianceId,
      'hours_per_day': hoursPerDay,
      'quantity': quantity,
      'priority': priority,
    });
  }

  /// تحديث جهاز
  Future<void> updateUserAppliance(
      int id, {
        double? hoursPerDay,
        int? quantity,
        String? priority,
      }) async {
    final data = <String, dynamic>{};

    if (hoursPerDay != null) data['hours_per_day'] = hoursPerDay;
    if (quantity != null) data['quantity'] = quantity;
    if (priority != null) data['priority'] = priority;

    await supabase.from('user_appliances').update(data).eq('id', id);
  }

  /// حذف جهاز
  Future<void> deleteUserAppliance(int id) async {
    await supabase.from('user_appliances').delete().eq('id', id);
  }
}