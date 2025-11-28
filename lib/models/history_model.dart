class UsageRecord {
  final String userId;
  final int reading;
  final int price;
  final DateTime createdAt;

  UsageRecord({
    required this.userId,
    required this.reading,
    required this.price,
    required this.createdAt,
  });

  factory UsageRecord.fromMap(Map<String, dynamic> map) {
    return UsageRecord(
      userId: map['user_id'],
      reading: map['reading'],
      price: map['price'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'reading': reading,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
