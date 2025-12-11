class UserAppliance {
  final int? id;
  final int? applianceId; // لو الجهاز جاهز → ID، لو مخصص → null

  // بيانات الجهاز الجاهز من جدول appliances
  final String? name;
  final String? brand;
  final int? watt;

  // بيانات الجهاز المخصص
  final String? customName;
  final String? customBrand;
  final int? customWatt;

  final double hoursPerDay;
  final int quantity;
  final String priority;

  UserAppliance({
    this.id,
    this.applianceId,
    this.name,
    this.brand,
    this.watt,
    this.customName,
    this.customBrand,
    this.customWatt,
    required this.hoursPerDay,
    this.quantity = 1,
    this.priority = "not_important",
  });

  /// --------------------------
  ///   fromJson (بدون dynamic)
  /// --------------------------
  factory UserAppliance.fromJson(Map<String, Object?> json) {
    // Read nested "appliances" safely
    final appliancesJson = json['appliances'] as Map<String, Object?>?;

    return UserAppliance(
      id: json['id'] as int?,
      applianceId: json['appliance_id'] as int?,
      name: appliancesJson != null ? appliancesJson['name'] as String? : null,
      brand: appliancesJson != null ? appliancesJson['brand'] as String? : null,
      watt: appliancesJson != null ? appliancesJson['watt'] as int? : null,

      // لو الجهاز مخصص
      customName: json['custom_name'] as String?,
      customBrand: json['custom_brand'] as String?,
      customWatt: json['custom_watt'] as int?,

      hoursPerDay: (json['hours_per_day'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      priority: json['priority'] as String? ?? "not_important",
    );
  }

  /// --------------------------
  ///   JSON for INSERT/UPDATE
  /// --------------------------
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'appliance_id': applianceId,
      'custom_name': customName,
      'custom_brand': customBrand,
      'custom_watt': customWatt,
      'hours_per_day': hoursPerDay,
      'quantity': quantity,
      'priority': priority,
    };
  }

  /// --------------------------
  ///   copyWith
  /// --------------------------
  UserAppliance copyWith({
    int? id,
    double? hoursPerDay,
    int? quantity,
    String? priority,
  }) {
    return UserAppliance(
      id: id ?? this.id,
      applianceId: applianceId,
      name: name,
      brand: brand,
      watt: watt,
      customName: customName,
      customBrand: customBrand,
      customWatt: customWatt,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      quantity: quantity ?? this.quantity,
      priority: priority ?? this.priority,
    );
  }

  /// --------------------------
  /// Getter مفيد: Watt الفعلي
  /// --------------------------
  int get effectiveWatt => watt ?? customWatt ?? 0;

  /// Getter للاسم الصحيح
  String get displayName => name ?? customName ?? "Unknown Device";
}