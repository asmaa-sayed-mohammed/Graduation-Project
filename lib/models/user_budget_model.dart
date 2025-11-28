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
      id: json['id'] as int? ?? 0, // Handle null case
      userId: json['user_id'] as String? ?? '', // Handle null case
      monthlyBudget: (json['monthly_budget'] as num?)?.toDouble() ?? 0.0, // Handle null case
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(), // Default to now if null
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(), // Default to now if null
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

  // Create a copyWith method for easy updates
  UserBudget copyWith({
    int? id,
    String? userId,
    double? monthlyBudget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserBudget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to check if budget is valid
  bool get isValid => monthlyBudget > 0 && userId.isNotEmpty;

  // Helper method to get formatted budget
  String get formattedBudget => '${monthlyBudget.toStringAsFixed(2)} جنيه';

  @override
  String toString() {
    return 'UserBudget(id: $id, userId: $userId, monthlyBudget: $monthlyBudget, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserBudget &&
        other.id == id &&
        other.userId == userId &&
        other.monthlyBudget == monthlyBudget;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ monthlyBudget.hashCode;
  }
}