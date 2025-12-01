class UserBudget {
  final int id;
  final String userId;
  final DateTime month;
  final double budget;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserBudget({
    required this.id,
    required this.userId,
    required this.month,
    required this.budget,
    this.createdAt,
    this.updatedAt,
  });

  factory UserBudget.fromMap(Map<String, dynamic> map) {
    return UserBudget(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      month: DateTime.parse(map['month'] as String),
      budget: (map['budget'] as num).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'month': month.toIso8601String(),
      'budget': budget,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}