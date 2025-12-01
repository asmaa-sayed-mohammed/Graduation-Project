import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_budget_model.dart';

class BudgetService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// جلب ميزانية الشهر الحالي للمستخدم
  Future<UserBudget?> getCurrentMonthBudget(String userId) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final res = await _supabase
        .from('user_budgets')
        .select()
        .eq('user_id', userId)
        .gte('month', firstDay.toIso8601String())
        .lte('month', lastDay.toIso8601String())
        .maybeSingle();

    if (res == null) return null;
    return UserBudget.fromMap(res);
  }

  /// إضافة أو تحديث ميزانية الشهر الحالي
  Future<void> insertOrUpdateBudget(String userId, double budget) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);

    await _supabase.from('user_budgets').upsert({
      'user_id': userId,
      'month': firstDay.toIso8601String(),
      'budget': budget,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,month'); // String مفرد مع العمودين
  }
}