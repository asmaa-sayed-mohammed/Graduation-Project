class UserAppliance {
  final int? id; // دلوقتي nullable
  final int applianceId;
  final String name;
  final String brand;
  final int watt;
  final double hoursPerDay;
  final int quantity;
  final String priority;

  UserAppliance({
    this.id, // مش required
    required this.applianceId,
    required this.name,
    required this.brand,
    required this.watt,
    required this.hoursPerDay,
    this.quantity = 1,
    this.priority = "not_important",
  });

  factory UserAppliance.fromJson(Map<String, dynamic> json) {
    return UserAppliance(
      id: json['id'], // لو موجود هيمرر، لو مش موجود هتبقى null
      applianceId: json['appliance_id'],
      name: json['appliances']?['name'] ?? '',
      brand: json['appliances']?['brand'] ?? '',
      watt: json['appliances']?['watt'] ?? 0,
      hoursPerDay: (json['hours_per_day'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      priority: json['priority'] ?? "not_important",
    );
  }

  UserAppliance copyWith({
    int? id, // لو عايز تحدثها
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
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      quantity: quantity ?? this.quantity,
      priority: priority ?? this.priority,
    );
  }
}