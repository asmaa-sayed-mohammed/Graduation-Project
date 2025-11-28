import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/appliance_service.dart';
import 'package:graduation_project/models/appliance_category_model.dart';
import 'package:graduation_project/models/appliance_model.dart';
import 'package:graduation_project/models/user_appliance_model.dart';

class AppliancesController extends GetxController {
  final ApplianceService _applianceService = ApplianceService();

  final RxList<ApplianceCategory> categories = <ApplianceCategory>[].obs;
  final Rxn<ApplianceCategory> selectedCategory = Rxn<ApplianceCategory>();
  final RxList<Appliance> appliances = <Appliance>[].obs;
  final RxList<UserAppliance> userAppliances = <UserAppliance>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;


  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    _loadUserAppliances(); // ⬅️ أضف هذا السطر
  }

  Future<void> _loadUserAppliances() async {
    try {
      final String userId = _applianceService.getCurrentUserId();
      if (userId.isNotEmpty) {
        final List<UserAppliance> loadedUserAppliances =
        await _applianceService.getUserAppliances(userId);
        userAppliances.assignAll(loadedUserAppliances);
      }
    } catch (e) {
      _showError('فشل في تحميل أجهزتك', e.toString());
    }
  }
  Future<void> _loadInitialData() async {
    try {
      isLoading.value = true;
      final List<ApplianceCategory> loadedCategories = await _applianceService.getCategories();
      categories.assignAll(loadedCategories);

      if (categories.isNotEmpty) {
        selectedCategory.value = categories.first;
        await _loadAppliancesByCategory(categories.first);
      }
    } catch (e) {
      _showError('فشل في تحميل الفئات', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAppliancesByCategory(ApplianceCategory category) async {
    try {
      isLoading.value = true;
      appliances.clear();

      final List<Appliance> loadedAppliances = await _applianceService.getAppliancesByCategory(category.id);
      appliances.assignAll(loadedAppliances);
    } catch (e) {
      _showError('فشل في تحميل الأجهزة', e.toString());
      appliances.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(ApplianceCategory category) {
    appliances.clear();
    selectedCategory.value = category;
    _loadAppliancesByCategory(category);
  }

  void toggleApplianceSelection(Appliance appliance) {
    final int existingIndex = userAppliances.indexWhere((UserAppliance ua) => ua.applianceId == appliance.id);

    if (existingIndex != -1) {
      userAppliances.removeAt(existingIndex);
    } else {
      final UserAppliance userAppliance = UserAppliance(
        id: 0,
        userId: '',
        applianceId: appliance.id,
        brand: appliance.brand,
        model: '${appliance.name} - ${appliance.brand}',
        hoursPerDay: 4.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: null,
        appliance: appliance,
      );
      userAppliances.add(userAppliance);
    }
  }

  bool isApplianceSelected(Appliance appliance) {
    return userAppliances.any((UserAppliance ua) => ua.applianceId == appliance.id);
  }

  Future<void> saveUserAppliances() async {
    try {
      isSaving.value = true;
      await _applianceService.saveUserAppliances(userAppliances);
      _showSuccess('تم الحفظ', 'تم حفظ ${userAppliances.length} جهاز بنجاح');
      Get.back();
    } catch (e) {
      _showError('فشل في حفظ الأجهزة', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  void _showError(String title, String message) {
    Get.log('Error: $title - $message');
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  int get selectedAppliancesCount => userAppliances.length;
}