class Appliance {
  final int id;
  final String name;
  final String brand;
  final int watt;

  Appliance({
    required this.id,
    required this.name,
    required this.brand,
    required this.watt,
  });

  factory Appliance.fromMap(Map<String, dynamic> map) {
    return Appliance(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      watt: map['watt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'watt': watt,
    };
  }
}