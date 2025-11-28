import 'package:flutter/foundation.dart';

@immutable
class EnergyTip {
  final int id;
  final String title;
  final String description;
  final int? applianceId;
  final int priority;
  final DateTime createdAt;

  const EnergyTip({
    required this.id,
    required this.title,
    required this.description,
    this.applianceId,
    required this.priority,
    required this.createdAt,
  });

  factory EnergyTip.fromJson(Map<String, Object?> json) {
    return EnergyTip(
      id: _safeCastInt(json['id']),
      title: _safeCastString(json['title']),
      description: _safeCastString(json['description']),
      applianceId: json['appliance_id'] != null
          ? _safeCastInt(json['appliance_id'])
          : null,
      priority: _safeCastInt(json['priority']),
      createdAt: _safeCastDateTime(json['created_at']),
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

  static DateTime _safeCastDateTime(Object? value) {
    if (value == null) throw const FormatException('القيمة لا يمكن أن تكون null');
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    throw FormatException('قيمة وقت غير صالحة: $value');
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EnergyTip &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EnergyTip(id: $id, title: $title)';
}