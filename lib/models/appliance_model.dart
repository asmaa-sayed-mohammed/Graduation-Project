import 'package:flutter/foundation.dart';

@immutable
class Appliance {
  final int id;
  final int categoryId;
  final String nameAr;
  final String brand;
  final int watt;

  const Appliance({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.brand,
    required this.watt,
  });

  factory Appliance.fromJson(Map<String, Object?> json) {
    return Appliance(
      id: _safeCastInt(json['id']),
      categoryId: _safeCastInt(json['category_id']),
      nameAr: _safeCastString(json['name_ar']),
      brand: _safeCastString(json['brand']),
      watt: _safeCastInt(json['watt']),
    );
  }

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

  String get name => nameAr;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Appliance &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Appliance(id: $id, nameAr: $nameAr, watt: $watt)';
}