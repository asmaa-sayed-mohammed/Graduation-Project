import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/services/appliance_service.dart';
import 'package:graduation_project/models/appliance_category_model.dart';
import 'package:graduation_project/models/appliance_model.dart';
import 'package:graduation_project/models/user_appliance_model.dart';

class AppliancesController extends GetxController {
  final ApplianceService _applianceService = ApplianceService();

  // متغيرات مراقبة
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
    _loadUserAppliances();
  }

  // تحميل الفئات والأجهزة الأولى
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

  // تحميل أجهزة فئة معينة
  Future<void> _loadAppliancesByCategory(ApplianceCategory category) async {
    try {
      isLoading.value = true;
      appliances.clear();

      final List<Appliance> loadedAppliances =
      await _applianceService.getAppliancesByCategory(category.id);
      appliances.assignAll(loadedAppliances);
    } catch (e) {
      _showError('فشل في تحميل الأجهزة', e.toString());
      appliances.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // اختيار فئة
  Future<void> selectCategory(ApplianceCategory category) async {
    selectedCategory.value = category;
    await _loadAppliancesByCategory(category);
  }

  // تحميل الأجهزة الخاصة بالمستخدم
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

  // تحديث جهاز المستخدم
  Future<void> updateUserAppliance(UserAppliance userAppliance) async {
    try {
      await _applianceService.updateUserAppliance(userAppliance);
      final index = userAppliances.indexWhere((ua) => ua.id == userAppliance.id);
      if (index != -1) {
        userAppliances[index] = userAppliance;
      }
      _showSuccess('تم التحديث', 'تم تعديل الجهاز بنجاح');
    } catch (e) {
      _showError('فشل في التحديث', e.toString());
    }
  }

  // حذف جهاز المستخدم
  Future<void> deleteUserAppliance(int userApplianceId) async {
    try {
      await _applianceService.deleteUserAppliance(userApplianceId);
      userAppliances.removeWhere((ua) => ua.id == userApplianceId);
      _showSuccess('تم الحذف', 'تم حذف الجهاز بنجاح');
    } catch (e) {
      _showError('فشل في الحذف', e.toString());
    }
  }

  // اختيار الجهاز بالبراند (البراند موجود بالفعل في Appliance)
  void showBrandSelection(Appliance appliance) {
    // لأن كل جهاز له براند واحد فقط، نستخدمه مباشرة
    toggleApplianceSelection(appliance, appliance.brand);
  }

  // تفعيل أو إلغاء اختيار الجهاز
  void toggleApplianceSelection(Appliance appliance, String brand) {
    final int existingIndex = userAppliances.indexWhere(
            (ua) => ua.applianceId == appliance.id && ua.brand == brand);

    if (existingIndex != -1) {
      userAppliances.removeAt(existingIndex);
    } else {
      final UserAppliance userAppliance = UserAppliance(
        id: 0,
        userId: '',
        applianceId: appliance.id,
        brand: brand,
        model: '${appliance.nameAr} - $brand',
        hoursPerDay: 4.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: null,
        appliance: appliance,
      );
      userAppliances.add(userAppliance);
    }
  }

  // التحقق من اختيار جهاز محدد بالبراند
  bool isApplianceSelected(Appliance appliance) {
    return userAppliances.any(
            (ua) => ua.applianceId == appliance.id && ua.brand == appliance.brand);
  }

  // حفظ الأجهزة المختارة
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

  // عدد الأجهزة المختارة
  int get selectedAppliancesCount => userAppliances.length;

  // رسائل الخطأ
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

  // رسائل النجاح
  void _showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
