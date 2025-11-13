// models/user_appliance_model.dart
import 'appliance_model.dart';

class UserAppliance {
  final int id;
  final String userId;
  final int applianceId;
  final String? brand;
  final String? model;
  final double hoursPerDay;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // العلاقة مع جدول الأجهزة
  final Appliance? appliance;

  UserAppliance({
    required this.id,
    required this.userId,
    required this.applianceId,
    this.brand,
    this.model,
    required this.hoursPerDay,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.appliance,
  });

  factory UserAppliance.fromJson(Map<String, dynamic> json) {
    return UserAppliance(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      applianceId: json['appliance_id'] as int,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      hoursPerDay: (json['hours_per_day'] as num).toDouble(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      appliance: json['appliances'] != null
          ? Appliance.fromJson(json['appliances'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'appliance_id': applianceId,
      'brand': brand,
      'model': model,
      'hours_per_day': hoursPerDay,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // حساب الاستهلاك اليومي
  double get dailyConsumption {
    if (appliance == null) return 0.0;
    return (appliance!.avgWattage * hoursPerDay) / 1000; // كيلوواط ساعة
  }

  // حساب الاستهلاك الشهري
  double get monthlyConsumption {
    return dailyConsumption * 30;
  }

  // حساب التكلفة الشهرية (بافتراض سعر 1.5 جنيه للكيلوواط ساعة)
  double get monthlyCost {
    return monthlyConsumption * 1.5;
  }

  // الحصول على معلومات الجهاز بشكل آمن
  String get applianceName {
    return appliance?.nameAr ?? 'جهاز غير معروف';
  }

  String get wattageInfo {
    if (appliance == null) return 'غير معروف';
    return appliance!.wattageDisplay;
  }

  // دالة لتحديث ساعات الاستخدام
  UserAppliance copyWith({
    double? hoursPerDay,
    String? brand,
    String? model,
    bool? isActive,
  }) {
    return UserAppliance(
      id: id,
      userId: userId,
      applianceId: applianceId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      appliance: appliance,
    );
  }
}