import 'package:flutter/foundation.dart';
import 'appliance_model.dart';

@immutable
class UserAppliance {
  final int id;
  final String userId;
  final int applianceId;
  final String brand;
  final String model;
  final double hoursPerDay;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Appliance? appliance;

  const UserAppliance({
    required this.id,
    required this.userId,
    required this.applianceId,
    required this.brand,
    required this.model,
    required this.hoursPerDay,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.appliance,
  });

  factory UserAppliance.fromJson(Map<String, Object?> json) {
    final Object? applianceData = json['appliances'];
    final Map<String, Object?>? applianceJson =
    applianceData is Map<String, Object?> ? applianceData : null;

    return UserAppliance(
      id: _safeCastInt(json['id']),
      userId: _safeCastString(json['user_id']),
      applianceId: _safeCastInt(json['appliance_id']),
      brand: _getBrand(json['brand']),
      model: _getModel(json['model']),
      hoursPerDay: _getHoursPerDay(json['hours_per_day']),
      isActive: _getIsActive(json['is_active']),
      createdAt: _safeCastDateTime(json['created_at']),
      updatedAt: json['updated_at'] != null ? _safeCastNullableDateTime(json['updated_at']) : null,
      appliance: applianceJson != null ? Appliance.fromJson(applianceJson) : null,
    );
  }

  // الدوال المساعدة مضافة هنا مباشرة
  static int _safeCastInt(Object? value) {
    if (value == null) throw const FormatException('القيمة لا يمكن أن تكون null');
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    throw FormatException('قيمة غير صالحة لرقم: $value');
  }

  static String _safeCastString(Object? value) {
    if (value == null) throw const FormatException('القيمة لا يمكن أن تكون null');
    return value.toString();
  }

  static String? _safeCastNullableString(Object? value) {
    if (value == null) return null;
    return value.toString();
  }

  static DateTime _safeCastDateTime(Object? value) {
    if (value == null) throw const FormatException('القيمة لا يمكن أن تكون null');
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    throw FormatException('قيمة وقت غير صالحة: $value');
  }

  static DateTime? _safeCastNullableDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // الدوال الخاصة بـ UserAppliance
  static String _getBrand(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return 'عام';
  }

  static String _getModel(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return 'نموذج افتراضي';
  }

  static double _getHoursPerDay(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 4.0;
    return 4.0;
  }

  static bool _getIsActive(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return true;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserAppliance &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserAppliance(id: $id, applianceId: $applianceId)';
}