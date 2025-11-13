// controllers/appliances_controller.dart
import 'package:get/get.dart';
import 'package:graduation_project/services/appliance_service.dart';
import 'package:graduation_project/models/appliance_category_model.dart';
import 'package:graduation_project/models/appliance_model.dart';

class AppliancesController extends GetxController {
  final ApplianceService _applianceService = ApplianceService();

  var categories = <ApplianceCategory>[].obs;
  var selectedCategory = Rxn<ApplianceCategory>();
  var appliances = <Appliance>[].obs;
  var userAppliances = <Appliance>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      categories.value = await _applianceService.getCategories();
      // اختيار أول فئة افتراضياً
      if (categories.isNotEmpty) {
        selectCategory(categories.first);
      }
    } catch (e) {
      Get.log('Error loading categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAppliancesByCategory(ApplianceCategory category) async {
    try {
      // منع التحميل المكرر لنفس الفئة
      if (selectedCategory.value?.id == category.id && appliances.isNotEmpty) {
        return;
      }

      isLoading.value = true;
      appliances.value = await _applianceService.getAppliancesByCategory(category.id);
    } catch (e) {
      Get.log('Error loading appliances: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(ApplianceCategory category) {
    // منع التحديث المكرر
    if (selectedCategory.value?.id == category.id) return;

    selectedCategory.value = category;
    loadAppliancesByCategory(category);
  }

  void toggleApplianceSelection(Appliance appliance) {
    if (userAppliances.contains(appliance)) {
      userAppliances.remove(appliance);
    } else {
      userAppliances.add(appliance);
    }
  }

  bool isApplianceSelected(Appliance appliance) {
    return userAppliances.contains(appliance);
  }

  double get estimatedDailyConsumption {
    double total = 0.0;
    for (var appliance in userAppliances) {
      // افتراض 4 ساعات استخدام يومياً لكل جهاز
      total += (appliance.avgWattage * 4) / 1000;
    }
    return total;
  }

  // دالة مساعدة لتحويل Set إلى List إذا احتجت
  List<Appliance> get userAppliancesList => userAppliances.toList();
}