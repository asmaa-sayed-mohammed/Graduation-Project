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

  // متغيرات حفظ الاستهلاك حتى اليوم
  double storedUsedKwh = 0.0;
  double storedUsedCost = 0.0;
  int savedDay = DateTime.now().day;

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

  // حساب تكلفة استهلاك الكهرباء
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

  double _calcDailyKwh(UserAppliance d) => d.effectiveWatt * d.hoursPerDay * d.quantity / 1000;

  int daysLeftInMonth() {
    int today = DateTime.now().day;
    int daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    return daysInMonth - today;
  }

  // تحديث وحفظ الاستهلاك حتى اليوم (ثابت مهما أضيف أو حُذف جهاز)
  void updateStoredUsage() {
    int today = DateTime.now().day;

    // إذا تغير اليوم → إعادة ضبط
    if (today != savedDay) {
      storedUsedKwh = 0.0;
      storedUsedCost = 0.0;
      savedDay = today;
    }

    // احسب استهلاك الأجهزة الموجودة حتى اليوم مرة واحدة فقط
    if (storedUsedKwh == 0.0) {
      storedUsedKwh = appliancesController.userAppliances.fold(
        0.0,
            (sum, d) => sum + _calcDailyKwh(d) * today,
      );
      storedUsedCost = calculateCostFromKwh(storedUsedKwh);
    }
  }

  double calculateUsedKwh() => storedUsedKwh;
  double calculateUsedCost() => storedUsedCost;

  // استهلاك باقي الشهر لكل الأجهزة (بما فيها الجديدة)
  double calculateExpectedRemainingKwh() {
    int leftDays = daysLeftInMonth();
    return appliancesController.userAppliances.fold(
      0.0,
          (sum, d) => sum + _calcDailyKwh(d) * leftDays,
    );
  }

  double calculateExpectedRemainingCost() => calculateCostFromKwh(calculateExpectedRemainingKwh());

  double calculateTotalExpectedCost() => storedUsedCost + calculateExpectedRemainingCost();

  void generateRecommendations() {
    updateStoredUsage(); // ✅ تحديث الاستهلاك حتى اليوم قبل أي عملية

    final devices = appliancesController.userAppliances;
    if (devices.isEmpty) {
      recommendations.clear();
      return;
    }

    double monthlyBudget = budgetController.monthlyBudget.value;
    double usedKwh = calculateUsedKwh();
    double usedCost = calculateUsedCost();
    double expectedRemainingCost = calculateExpectedRemainingCost();
    double totalExpectedCost = calculateTotalExpectedCost();

    // اقتراحات التوفير للأجهزة غير المهمة
    List<UserAppliance> targetDevices = devices.where((d) => d.priority != "important").toList();
    final recs = _generateReductionOptions(targetDevices);

    final statusMap = {
      "cumulativeHistorical": homeController.getCumulativePrice(),
    };

    recommendations.assignAll([
      {
        "title": "الوضع الحالي",
        "usedKwh": usedKwh,
        "usedCost": usedCost,
        "expectedRemainingCost": expectedRemainingCost,
        "totalExpectedCost": totalExpectedCost,
        "monthlyBudget": monthlyBudget,
      },
      {
        "title": "اقتراحات التوفير لباقي الشهر",
        "changes": recs,
        "totalSavedEGP": recs.fold(0.0, (sum, r) => sum + (r["savedEGP"]?.toDouble() ?? 0.0)),
      },
      statusMap
    ]);
  }

  List<Map<String, dynamic>> _generateReductionOptions(List<UserAppliance> devices) {
    devices.sort((a, b) => _calcDailyKwh(b).compareTo(_calcDailyKwh(a)));
    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < devices.length && i < 3; i++) {
      final ua = devices[i];
      final displayName = ua.customName?.isNotEmpty == true ? ua.customName! : ua.name;
      final displayBrand = ua.customBrand?.isNotEmpty == true ? ua.customBrand! : ua.brand;
      int reduceHours = ua.hoursPerDay > 2 ? 2 : 1;
      double savedKwh = ua.effectiveWatt * reduceHours * ua.quantity * daysLeftInMonth() / 1000;
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
