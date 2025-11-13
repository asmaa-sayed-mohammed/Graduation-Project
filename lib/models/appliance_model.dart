// models/appliance_model.dart
import 'package:flutter/material.dart';

class Appliance {
  final int id;
  final int categoryId;
  final String nameAr;
  final String? nameEn;
  final int avgWattage;
  final int? minWattage;
  final int? maxWattage;
  final List<String> commonBrands;
  final String? usageTipsAr;

  Appliance({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    this.nameEn,
    required this.avgWattage,
    this.minWattage,
    this.maxWattage,
    required this.commonBrands,
    this.usageTipsAr,
  });

  factory Appliance.fromJson(Map<String, dynamic> json) {
    return Appliance(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      avgWattage: json['avg_wattage'] as int,
      minWattage: json['min_wattage'] as int?,
      maxWattage: json['max_wattage'] as int?,
      commonBrands: List<String>.from(json['common_brands'] ?? []),
      usageTipsAr: json['usage_tips_ar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'avg_wattage': avgWattage,
      'min_wattage': minWattage,
      'max_wattage': maxWattage,
      'common_brands': commonBrands,
      'usage_tips_ar': usageTipsAr,
    };
  }

  // دالة مساعدة لعرض استهلاك الطاقة
  String get wattageDisplay {
    if (minWattage != null && maxWattage != null) {
      return '$minWattage - $maxWattage واط';
    }
    return '$avgWattage واط';
  }

  // دالة لعرض الماركات كـ String
  String get brandsDisplay {
    return commonBrands.join('، ');
  }
}