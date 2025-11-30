import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetController extends GetxController {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  var monthlyBudget = 0.0.obs;
  var isLoading = false.obs;
  var hasBudget = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserBudget();
  }

  Future<void> loadUserBudget() async {
    try {
      isLoading.value = true;

      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabaseClient
          .from('user_budgets')
          .select()
          .eq('user_id', userId);

      // ✅ التحقق من null وليس isEmpty فقط
      if (response != null && response.isNotEmpty) {
        monthlyBudget.value = (response[0]['monthly_budget'] as num).toDouble();
        hasBudget.value = true;
      } else {
        hasBudget.value = false;
      }

    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تحميل الميزانية: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> saveBudget(double budget) async {
    try {
      isLoading.value = true;
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception('يجب تسجيل الدخول أولاً');

      // 1. احذف أي ميزانية موجودة
      await _supabaseClient
          .from('user_budgets')
          .delete()
          .eq('user_id', userId);

      // 2. أدرج الميزانية الجديدة
      await _supabaseClient
          .from('user_budgets')
          .insert({
        'user_id': userId,
        'monthly_budget': budget,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      monthlyBudget.value = budget;
      hasBudget.value = true;
      Get.snackbar('نجاح', 'تم حفظ الميزانية: $budget جنيه');

    } catch (e) {
      Get.snackbar('خطأ', 'فشل في الحفظ: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ دالة مساعدة للإدراج أو التحديث
  Future<void> _insertOrUpdateBudget(String userId, double budget) async {
    try {
      // أولاً حاول التحديث
      final updateResponse = await _supabaseClient
          .from('user_budgets')
          .update({
        'monthly_budget': budget,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', userId);

      // ✅ التحقق من null أولاً ثم isEmpty
      if (updateResponse == null || (updateResponse is List && updateResponse.isEmpty)) {
        // إذا التحديث فشل، قم بالإدراج
        await _supabaseClient
            .from('user_budgets')
            .insert({
          'user_id': userId,
          'monthly_budget': budget,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // إذا فشل التحديث، جرب الإدراج مباشرة
      await _supabaseClient
          .from('user_budgets')
          .insert({
        'user_id': userId,
        'monthly_budget': budget,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }
}

// ... باقي كلاس UserBudget يبقى كما هو
class UserBudget {
  final int id;
  final String userId;
  final double monthlyBudget;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserBudget({
    required this.id,
    required this.userId,
    required this.monthlyBudget,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserBudget.fromJson(Map<String, dynamic> json) {
    return UserBudget(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as String? ?? '',
      monthlyBudget: (json['monthly_budget'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'monthly_budget': monthlyBudget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserBudget copyWith({
    int? id,
    String? userId,
    double? monthlyBudget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserBudget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isValid => monthlyBudget > 0 && userId.isNotEmpty;

  String get formattedBudget => '${monthlyBudget.toStringAsFixed(2)} جنيه';

  @override
  String toString() {
    return 'UserBudget(id: $id, userId: $userId, monthlyBudget: $monthlyBudget, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserBudget &&
        other.id == id &&
        other.userId == userId &&
        other.monthlyBudget == monthlyBudget;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ monthlyBudget.hashCode;
  }
}