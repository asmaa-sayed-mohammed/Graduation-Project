import '../models/user_appliance_model.dart';

class SmartRecommendationService {
  final List<Map<String, dynamic>> _tariffs = [
    {"max": 50, "rate": 0.68},
    {"max": 100, "rate": 0.78},
    {"max": 200, "rate": 0.95},
    {"max": 350, "rate": 1.55},
    {"max": 650, "rate": 1.95},
    {"max": 1000, "rate": 2.10},
    {"max": double.infinity, "rate": 2.23},
  ];

  double calculateCost(double kwh) {
    for (var t in _tariffs) {
      if (kwh <= t["max"]) return kwh * t["rate"];
    }
    return kwh * 2.23;
  }

  double calculateMonthlyConsumption(UserAppliance ua) {
    return ua.watt * ua.hoursPerDay * ua.quantity * 30 / 1000;
  }

  List<Map<String, dynamic>> generateRecommendations({
    required List<UserAppliance> devices,
    required double monthlyBudget,
  }) {
    if (devices.isEmpty) return [];

    List<UserAppliance> important =
    devices.where((d) => d.priority == "important").toList();
    List<UserAppliance> nonImportant =
    devices.where((d) => d.priority != "important").toList();

    double importantConsumption =
    important.fold(0, (sum, d) => sum + calculateMonthlyConsumption(d));

    List<UserAppliance> targetDevices =
    importantConsumption > monthlyBudget ? important : nonImportant;

    return _generateReductionOptions(targetDevices);
  }

  List<Map<String, dynamic>> _generateReductionOptions(List<UserAppliance> devices) {
    if (devices.isEmpty) return [];

    devices.sort((a, b) =>
        calculateMonthlyConsumption(b).compareTo(calculateMonthlyConsumption(a)));

    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < devices.length && i < 3; i++) {
      final ua = devices[i];
      double reduceHours = ua.hoursPerDay > 2 ? 2 : 1;

      double savedKwh = ua.watt * reduceHours * ua.quantity * 30 / 1000;
      double savedEGP = calculateCost(savedKwh);

      results.add({
        "device": ua.name,
        "reduceHours": reduceHours,
        "savedEGP": savedEGP,
      });
    }

    double totalSaved = results.fold(0, (sum, r) => sum + (r["savedEGP"] ?? 0));
    results.add({"title": "اقتراحات التوفير", "changes": results, "totalSavedEGP": totalSaved});

    return results;
  }
}