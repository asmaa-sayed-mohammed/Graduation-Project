import 'package:get/get.dart';
import '../services/budget_service.dart';

class BudgetController extends GetxController {
  final BudgetService _service = BudgetService();

  final RxDouble monthlyBudget = 0.0.obs;
  final RxBool isLoading = false.obs;
  final Rx<DateTime?> lastUpdated = Rx<DateTime?>(null);

  late String userId;

  void init(String uid) {
    userId = uid;
    loadBudget();
  }

  Future<void> loadBudget() async {
    isLoading.value = true;
    final budget = await _service.getCurrentMonthBudget(userId);
    monthlyBudget.value = budget?.budget ?? 0.0;
    lastUpdated.value = budget?.updatedAt;
    isLoading.value = false;
  }

  Future<void> saveBudget(double value) async {
    if (value < 0) return;
    try {
      await _service.insertOrUpdateBudget(userId, value);
      monthlyBudget.value = value;
      lastUpdated.value = DateTime.now(); // تحديث وقت آخر حفظ
    } catch (e) {
      print(e);
    }finally{
      isLoading.value = false;
    }

  }
}