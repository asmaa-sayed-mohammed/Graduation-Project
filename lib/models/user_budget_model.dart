class UserBudget {
  final int id;
  final String userId;
  final double monthlyBudget;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserBudget({
    required this.id,
    required this.userId,
    required this.monthlyBudget,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserBudget.fromJson(Map<String, dynamic> json) {
    return UserBudget(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      monthlyBudget: (json['monthly_budget'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'monthly_budget': monthlyBudget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}