import 'package:get/get.dart';
import 'package:graduation_project/controllers/start_controller.dart';
import '../controllers/appliances_controller.dart';
import '../controllers/budget_controller.dart';
import '../models/user_appliance_model.dart';

class SmartRecommendationController extends GetxController {
  final AppliancesController appliancesController = Get.find();
  final BudgetController budgetController = Get.find();
  final HomeController homeController = Get.put(HomeController());

  final RxList<Map<String, dynamic>> recommendations = <Map<String, dynamic>>[].obs;
  double storedUsedKwh = 0.0;
  double storedUsedCost = 0.0;
  int savedDay = 0;

  @override
  void onInit() {
    super.onInit();
    ever<List<UserAppliance>>(appliancesController.userAppliances, (_) => generateRecommendations());
    ever(budgetController.monthlyBudget, (_) => generateRecommendations());
  }

  @override
  void onReady() {
    super.onReady();
    generateRecommendations();
  }
  void _updateStoredConsumptionIfNeeded() {
    int today = DateTime.now().day;

    if (savedDay != today) {
      storedUsedKwh = calculateUsedKwh();
      storedUsedCost = calculateUsedCost();
      savedDay = today;
    }
  }

  double calculateCostFromKwh(double kwh) {
    if (kwh == 0) return 9;
    double cost = 0.0;

    if (kwh <= 50) cost = kwh * 0.68;
    else if (kwh <= 100) cost = (50 * 0.68) + ((kwh - 50) * 0.78);
    else if (kwh <= 200) cost = kwh * 0.95;
    else if (kwh <= 350) cost = (200 * 0.95) + ((kwh - 200) * 1.55);
    else if (kwh <= 650) cost = (200 * 0.95) + (150 * 1.55) + ((kwh - 350) * 1.95);
    else if (kwh <= 1000) cost = kwh * 2.10;
    else cost = kwh * 2.23;

    double service = 0;
    if (kwh <= 50) service = 1;
    else if (kwh <= 100) service = 2;
    else if (kwh <= 200) service = 6;
    else if (kwh <= 350) service = 11;
    else if (kwh <= 650) service = 15;
    else if (kwh <= 1000) service = 25;
    else service = 40;

    return double.parse((cost + service).toStringAsFixed(2));
  }

  double _calcDailyKwh(UserAppliance d) =>
      d.effectiveWatt * d.hoursPerDay * d.quantity / 1000;

  int daysLeftInMonth() {
    int today = DateTime.now().day;
    int daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    return daysInMonth - today;
  }

  double calculateUsedKwh() {
    int today = DateTime.now().day;
    return appliancesController.userAppliances.fold(0.0, (sum, d) =>
    sum + _calcDailyKwh(d) * today);
  }

  double calculateUsedCost() => calculateCostFromKwh(calculateUsedKwh());

  double calculateExpectedRemainingKwh() {
    int leftDays = daysLeftInMonth();
    return appliancesController.userAppliances.fold(0.0, (sum, d) =>
    sum + _calcDailyKwh(d) * leftDays);
  }

  double calculateExpectedRemainingCost() =>
      calculateCostFromKwh(calculateExpectedRemainingKwh());

  double calculateTotalExpectedCost() =>
      storedUsedCost + calculateExpectedRemainingCost();

  void generateRecommendations() {
    final devices = appliancesController.userAppliances;
    if (devices.isEmpty) {
      recommendations.clear();
      return;
    }
    _updateStoredConsumptionIfNeeded();

    double monthlyBudget = budgetController.monthlyBudget.value;

    double expectedRemainingCost = calculateExpectedRemainingCost();
    double totalExpectedCost = calculateTotalExpectedCost();

    List<UserAppliance> targetDevices =
    devices.where((d) => d.priority != "important").toList();

    final recs = _generateReductionOptions(targetDevices);

    final statusMap = {
      "cumulativeHistorical": homeController.getCumulativePrice(),
    };

    recommendations.assignAll([
      {
        "title": "الوضع الحالي",
        "usedKwh": storedUsedKwh,
        "usedCost": storedUsedCost,
        "expectedRemainingCost": expectedRemainingCost,
        "totalExpectedCost": totalExpectedCost,
        "monthlyBudget": monthlyBudget,
      },
      {
        "title": "اقتراحات التوفير لباقي الشهر",
        "changes": recs,
        "totalSavedEGP": recs.fold(
            0.0, (sum, r) => sum + (r["savedEGP"]?.toDouble() ?? 0.0)),
      },
      statusMap
    ]);
  }

  List<Map<String, dynamic>> _generateReductionOptions(List<UserAppliance> devices) {
    devices.sort((a, b) => _calcDailyKwh(b).compareTo(_calcDailyKwh(a)));
    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < devices.length && i < 3; i++) {
      final ua = devices[i];
      final displayName =
      ua.customName?.isNotEmpty == true ? ua.customName! : ua.name;
      final displayBrand =
      ua.customBrand?.isNotEmpty == true ? ua.customBrand! : ua.brand;

      int reduceHours = ua.hoursPerDay > 2 ? 2 : 1;
      double savedKwh =
          ua.effectiveWatt * reduceHours * ua.quantity * daysLeftInMonth() / 1000;
      double savedEGP = calculateCostFromKwh(savedKwh);

      results.add({
        "device": displayName,
        "brand": displayBrand,
        "reduceHours": reduceHours,
        "savedEGP": savedEGP,
      });
    }
    return results;
  }
}
