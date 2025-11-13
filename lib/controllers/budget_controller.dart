// controllers/budget_controller.dart
import 'package:get/get.dart'; // ✅ إضافة هذا
import 'package:graduation_project/services/appliance_service.dart'; // ✅
import 'package:graduation_project/core/style/colors.dart'; // ✅

class BudgetController extends GetxController {
  final ApplianceService _applianceService = ApplianceService(); // ✅ الآن معرف

  var monthlyBudget = 0.0.obs;
  var isLoading = false.obs;
  var hasBudget = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserBudget();
  }

  Future<void> loadUserBudget() async {
    try {
      isLoading.value = true;
      // مؤقتاً نستخدم تخزين محلي
      final savedBudget = await _getLocalBudget();
      if (savedBudget > 0) {
        monthlyBudget.value = savedBudget;
        hasBudget.value = true;
      }
    } catch (e) {
      Get.log('Error loading budget: $e'); // ✅ بدلاً من print
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveBudget(double budget) async {
    try {
      isLoading.value = true;

      // حفظ محلي مؤقت
      await _saveLocalBudget(budget);

      monthlyBudget.value = budget;
      hasBudget.value = true;

      Get.back();
      Get.snackbar(
        'تم الحفظ!',
        'تم تعيين الميزانية الشهرية: $budget جنيه',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.green,
        colorText: AppColor.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حفظ الميزانية',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.red,
        colorText: AppColor.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveLocalBudget(double budget) async {
    // سنستبدل هذا لاحقاً
  }

  Future<double> _getLocalBudget() async {
    return 0.0;
  }
}