// lib/models/manual_calculation_result.dart

class ManualCalculationResult {
  final double consumption;
  final double totalPrice;
  final int tier;
  final bool hasError;
  final String? message;

  ManualCalculationResult({
    required this.consumption,
    required this.totalPrice,
    required this.tier,
    this.hasError = false,
    this.message,
  });

  // مصنع لإنشاء حالة خطأ بسهولة
  factory ManualCalculationResult.error(String msg) {
    return ManualCalculationResult(
      consumption: 0.0,
      totalPrice: 0.0,
      tier: 0,
      hasError: true,
      message: msg,
    );
  }

  // getter إضافي لتوافق الكود القديم
  String? get errorMessage => message;

  Map<String, dynamic> toMap() {
    return {
      'consumption': consumption,
      'totalPrice': totalPrice,
      'tier': tier,
      'hasError': hasError,
      'message': message,
    };
  }

  factory ManualCalculationResult.fromMap(Map<String, dynamic> map) {
    return ManualCalculationResult(
      consumption: (map['consumption'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      tier: (map['tier'] as int?) ?? 0,
      hasError: map['hasError'] as bool? ?? false,
      message: map['message'] as String?,
    );
  }
}
