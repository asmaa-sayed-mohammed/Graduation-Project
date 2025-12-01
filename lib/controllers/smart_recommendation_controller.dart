import 'package:get/get.dart';
import '../controllers/appliances_controller.dart';
import '../controllers/budget_controller.dart';
import '../models/user_appliance_model.dart';

class SmartRecommendationController extends GetxController {
  final AppliancesController appliancesController = Get.find();
  final BudgetController budgetController = Get.find();

  final RxList<Map<String, dynamic>> recommendations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    // عند أي تغيير في الأجهزة، توليد التوصيات تلقائيًا
    ever<List<UserAppliance>>(appliancesController.userAppliances, (_) {
      generateRecommendations();
    });
  }

  void generateRecommendations() {
    final List<UserAppliance> userDevices = appliancesController.userAppliances;

    if (userDevices.isEmpty) {
      recommendations.clear();
      return;
    }

    // فصل الأجهزة المهمة وغير المهمة
    List<UserAppliance> important = [];
    List<UserAppliance> nonImportant = [];

    for (var ua in userDevices) {
      if (ua.priority == "important") {
        important.add(ua);
      } else {
        nonImportant.add(ua);
      }
    }

    double totalBudget = budgetController.monthlyBudget.value;
    double importantConsumption = _calcConsumption(important);

    // ------------------------------------------------
    // توليد التوصيات
    // ------------------------------------------------
    List<Map<String, dynamic>> recs = [];

    if (importantConsumption > totalBudget) {
      recs = _generateReductionOptions(important);
    } else {
      recs = _generateReductionOptions(nonImportant);
    }

    recommendations.assignAll(recs);
  }

  double _calcConsumption(List<UserAppliance> devices) {
    double total = 0;
    for (var d in devices) {
      total += d.watt * d.hoursPerDay * d.quantity * 30 / 1000; // kWh شهريًا
    }
    return total;
  }

  List<Map<String, dynamic>> _generateReductionOptions(List<UserAppliance> devices) {
    List<Map<String, dynamic>> results = [];

    devices.sort((a, b) =>
        (b.watt * b.hoursPerDay).compareTo(a.watt * a.hoursPerDay));

    for (int i = 0; i < devices.length && i < 3; i++) {
      final ua = devices[i];
      int reduceHours = ua.hoursPerDay > 2 ? 2 : 1;
      double savedEGP = _calculateCost(ua, reduceHours);

      results.add({
        "device": ua.name,
        "reduceHours": reduceHours,
        "savedEGP": savedEGP,
      });
    }

    return results;
  }

  double _calculateCost(UserAppliance ua, int reduceHours) {
    double monthlyKwhSaved = ua.watt * reduceHours * ua.quantity * 30 / 1000;

    double cost = 0;

    if (monthlyKwhSaved <= 50) {
      cost = monthlyKwhSaved * 0.68;
    } else if (monthlyKwhSaved <= 100) {
      cost = monthlyKwhSaved * 0.78;
    } else if (monthlyKwhSaved <= 200) {
      cost = monthlyKwhSaved * 0.95;
    } else if (monthlyKwhSaved <= 350) {
      cost = monthlyKwhSaved * 1.55;
    } else if (monthlyKwhSaved <= 650) {
      cost = monthlyKwhSaved * 1.95;
    } else if (monthlyKwhSaved <= 1000) {
      cost = monthlyKwhSaved * 2.10;
    } else {
      cost = monthlyKwhSaved * 2.23;
    }

    return cost;
  }
}