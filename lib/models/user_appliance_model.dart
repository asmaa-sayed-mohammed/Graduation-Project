class UserAppliance {
  final int id;
  final int applianceId;
  final String name;
  final String brand;
  final int watt;
  final double hoursPerDay;
  final int quantity;
  final String priority;

  UserAppliance({
    required this.id,
    required this.applianceId,
    required this.name,
    required this.brand,
    required this.watt,
    required this.hoursPerDay,
    required this.quantity,
    required this.priority,
  });

  factory UserAppliance.fromJson(Map<String, dynamic> json) {
    return UserAppliance(
      id: json['id'],
      applianceId: json['appliance_id'],
      name: json['appliances']['name'],
      brand: json['appliances']['brand'],
      watt: json['appliances']['watt'],
      hoursPerDay: json['hours_per_day'].toDouble(),
      quantity: json['quantity'] ?? 1,
      priority: json['priority'] ?? "not_important",
    );
  }

  UserAppliance copyWith({
    double? hoursPerDay,
    int? quantity,
    String? priority,
  }) {
    return UserAppliance(
      id: id,
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