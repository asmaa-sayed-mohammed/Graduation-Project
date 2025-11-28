import 'package:flutter/foundation.dart';

@immutable
class ApplianceCategory {
  final int id;
  final String nameAr;
  final String? iconName;

  const ApplianceCategory({
    required this.id,
    required this.nameAr,
    this.iconName,
  });

  factory ApplianceCategory.fromJson(Map<String, Object?> json) {
    return ApplianceCategory(
      id: _safeCastInt(json['id']),
      nameAr: _safeCastString(json['name_ar']),
      iconName: _safeCastNullableString(json['icon_name']),
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

  String get name => nameAr;
  String? get icon => iconName;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ApplianceCategory &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ApplianceCategory(id: $id, nameAr: $nameAr)';
}