// controllers/tips_controller.dart
import 'package:get/get.dart';
import 'package:graduation_project/services/appliance_service.dart';
import 'package:graduation_project/models/energy_tip_model.dart';
import 'package:flutter/material.dart';

class TipsController extends GetxController {
  final ApplianceService _applianceService = ApplianceService();

  var allTips = <EnergyTip>[].obs;
  var filteredTips = <EnergyTip>[].obs;
  var isLoading = false.obs;
  var selectedPriority = 'ALL'.obs;

  @override
  void onInit() {
    super.onInit();
    loadEnergyTips();
  }

  Future<void> loadEnergyTips() async {
    try {
      isLoading.value = true;
      allTips.value = await _applianceService.getAllEnergyTips();
      filteredTips.value = allTips;
    } catch (e) {
      Get.log('Error loading energy tips: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByPriority(String priority) {
    selectedPriority.value = priority;

    if (priority == 'ALL') {
      filteredTips.value = allTips;
    } else {
      filteredTips.value = allTips
          .where((tip) => tip.priority == priority)
          .toList();
    }
  }

  String getPriorityText(String priority) {
    switch (priority) {
      case 'HIGH':
        return 'عالي';
      case 'MEDIUM':
        return 'متوسط';
      case 'LOW':
        return 'منخفض';
      default:
        return 'جميع المستويات';
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'HIGH':
        return const Color(0xFFE53935);
      case 'MEDIUM':
        return const Color(0xFFFB8C00);
      case 'LOW':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF757575);
    }
  }
}