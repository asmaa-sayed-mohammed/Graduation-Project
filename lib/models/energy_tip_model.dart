// models/energy_tip_model.dart
import 'appliance_model.dart';

class EnergyTip {
  final int id;
  final int applianceId;
  final String tipAr;
  final String? tipEn;
  final String priority;
  final String? conditions;
  final DateTime createdAt;

  final Appliance? appliance;

  EnergyTip({
    required this.id,
    required this.applianceId,
    required this.tipAr,
    this.tipEn,
    required this.priority,
    this.conditions,
    required this.createdAt,
    this.appliance,
  });

  factory EnergyTip.fromJson(Map<String, dynamic> json) {
    return EnergyTip(
      id: json['id'] as int,
      applianceId: json['appliance_id'] as int,
      tipAr: json['tip_ar'] as String,
      tipEn: json['tip_en'] as String?,
      priority: json['priority'] as String,
      conditions: json['conditions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      appliance: json['appliances'] != null
          ? Appliance.fromJson(json['appliances'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appliance_id': applianceId,
      'tip_ar': tipAr,
      'tip_en': tipEn,
      'priority': priority,
      'conditions': conditions,
      'created_at': createdAt.toIso8601String(),
    };
  }
}