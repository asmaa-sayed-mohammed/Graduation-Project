import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/appliances_controller.dart';
import 'package:graduation_project/controllers/bottom_navbar_controller.dart';
import '../core/style/colors.dart';
import '../core/widgets/bottom_navbar.dart';

class AppliancesScreen extends StatelessWidget {
  final AppliancesController controller = Get.find<AppliancesController>();

  AppliancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white2,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  Widget _buildAppliancesRow() {
    return Obx(() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.appliances.map((appliance) {
          final bool isSelected = controller.isApplianceSelected(appliance);
          return GestureDetector(
            onTap: () => controller.showBrandSelection(appliance),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow.shade600 : AppColor.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.yellow.shade800 : AppColor.gray2.withOpacity(0.3),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getApplianceIcon(appliance.nameAr),
                    color: isSelected ? AppColor.black : AppColor.primary_color,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appliance.nameAr,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                      color: AppColor.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appliance.brand,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColor.gray,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  Text(
                    '${appliance.watt} واط',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColor.gray,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

// دالة لتحديد أيقونة الجهاز حسب اسمه
  IconData _getApplianceIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('ثلاجة')) return Icons.kitchen;
    if (lowerName.contains('غسالة')) return Icons.local_laundry_service;
    if (lowerName.contains('مكيف')) return Icons.ac_unit;
    if (lowerName.contains('تلفزيون')) return Icons.tv;
    if (lowerName.contains('سخان')) return Icons.whatshot;
    if (lowerName.contains('مروحة')) return Icons.air;
    if (lowerName.contains('ميكروويف')) return Icons.microwave;
    if (lowerName.contains('لابتوب') || lowerName.contains('كمبيوتر')) return Icons.computer;
    if (lowerName.contains('شاحن')) return Icons.battery_charging_full;
    if (lowerName.contains('إضاءة')) return Icons.lightbulb_outline;
    if (lowerName.contains('مكنسة')) return Icons.cleaning_services;
    if (lowerName.contains('طباخة')) return Icons.coffee_maker;
    if (lowerName.contains('مضخة')) return Icons.water;
    if (lowerName.contains('صحون')) return Icons.dining;
    return Icons.devices_other;
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.primary_color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(120),
          bottomRight: Radius.circular(120),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Text(
            'اختر أجهزتك',
            style: TextStyle(
              color: AppColor.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'الفئات',
              style: TextStyle(
                color: AppColor.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoriesRow(),
            if (controller.appliances.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'الأجهزة',
                style: TextStyle(
                  color: AppColor.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 12),
              _buildAppliancesRow(),
            ],
          ],
        ),
      );
    });
  }

  // الفئات صغيرة جداً على طول النص
  Widget _buildCategoriesRow() {
    return Obx(() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.categories.map((category) {
          final bool isSelected = controller.selectedCategory.value?.id == category.id;
          return GestureDetector(
            onTap: () => controller.selectCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primary_color : AppColor.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColor.primary_color : AppColor.gray2.withOpacity(0.3),
                  width: 1.2,
                ),
              ),
              child: Text(
                category.nameAr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColor.white : AppColor.black,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      if (controller.selectedAppliancesCount == 0) return const SizedBox.shrink();

      return FloatingActionButton.extended(
        onPressed: controller.isSaving.value ? null : controller.saveUserAppliances,
        backgroundColor: AppColor.primary_color,
        foregroundColor: AppColor.black,
        label: Text(
          controller.isSaving.value
              ? 'جاري الحفظ...'
              : 'حفظ ${controller.selectedAppliancesCount} جهاز',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: controller.isSaving.value
            ? SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.black),
        )
            : const Icon(Icons.save_alt_rounded),
      );
    });
  }
}
