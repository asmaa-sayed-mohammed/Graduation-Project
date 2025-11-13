import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/appliances_controller.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/models/appliance_model.dart';

class AppliancesScreen extends StatelessWidget {
  const AppliancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppliancesController>(
      init: AppliancesController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.white,
          appBar: AppBar(
            backgroundColor: AppColor.primary_color,
            title: Text(
              'إدارة الأجهزة',
              style: TextStyle(
                color: AppColor.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColor.black),
              onPressed: () => Get.back(),
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              // فئات الأجهزة
              _buildCategoriesSection(controller),

              // قائمة الأجهزة
              Expanded(child: _buildAppliancesSection(controller)),

              // التقدير والإحصاءات
              _buildStatisticsSection(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection(AppliancesController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white2,
        border: Border(bottom: BorderSide(color: AppColor.gray2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر الفئة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                final isSelected = controller.selectedCategory.value?.id == category.id;

                return _buildCategoryItem(controller, category, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(AppliancesController controller, dynamic category, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectCategory(category),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary_color : AppColor.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColor.primary_color : AppColor.gray2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category.id),
              color: isSelected ? AppColor.white : AppColor.primary_color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              category.nameAr,
              style: TextStyle(
                color: isSelected ? AppColor.white : AppColor.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1: return Icons.ac_unit;
      case 2: return Icons.home;
      case 3: return Icons.tv;
      case 4: return Icons.kitchen;
      case 5: return Icons.lightbulb;
      case 6: return Icons.computer;
      case 7: return Icons.whatshot;
      default: return Icons.electrical_services;
    }
  }

  Widget _buildAppliancesSection(AppliancesController controller) {
    if (controller.selectedCategory.value == null) {
      return _buildEmptyState('اختر فئة لرؤية الأجهزة');
    }

    if (controller.isLoading.value) {
      return _buildLoadingState();
    }

    if (controller.appliances.isEmpty) {
      return _buildEmptyState('لا توجد أجهزة في هذه الفئة');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.appliances.length,
      itemBuilder: (context, index) {
        final appliance = controller.appliances[index];
        final isSelected = controller.isApplianceSelected(appliance);

        return _buildApplianceItem(controller, appliance, isSelected);
      },
    );
  }

  Widget _buildApplianceItem(AppliancesController controller, Appliance appliance, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColor.primary_color : AppColor.gray2,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primary_color.withOpacity(0.1) : AppColor.white2,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.electrical_services,
            color: isSelected ? AppColor.primary_color : AppColor.gray,
          ),
        ),
        title: Text(
          appliance.nameAr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.bolt, size: 12, color: AppColor.primary_color),
                const SizedBox(width: 4),
                Text(
                  appliance.wattageDisplay,
                  style: TextStyle(
                    color: AppColor.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (appliance.commonBrands.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'ماركات: ${appliance.brandsDisplay}',
                style: TextStyle(
                  color: AppColor.gray,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColor.primary_color : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColor.primary_color : AppColor.gray2,
            ),
          ),
          child: isSelected
              ? Icon(Icons.check, size: 16, color: AppColor.white)
              : null,
        ),
        onTap: () => controller.toggleApplianceSelection(appliance),
      ),
    );
  }

  Widget _buildStatisticsSection(AppliancesController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white2,
        border: Border(top: BorderSide(color: AppColor.gray2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإحصائيات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.black,
                  fontSize: 16,
                ),
              ),
              Text(
                '${controller.userAppliances.length} جهاز',
                style: TextStyle(
                  color: AppColor.primary_color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                'الاستهلاك اليومي',
                '${controller.estimatedDailyConsumption.toStringAsFixed(1)} kWh',
                Icons.bolt,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                'التكلفة الشهرية',
                '${(controller.estimatedDailyConsumption * 30 * 1.5).toStringAsFixed(0)} جنيه',
                Icons.attach_money,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.userAppliances.isNotEmpty ? () => _saveAppliances(controller) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary_color,
                foregroundColor: AppColor.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'حفظ الأجهزة المختارة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.gray2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColor.primary_color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.black,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColor.gray,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColor.primary_color),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الأجهزة...',
            style: TextStyle(
              color: AppColor.gray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 64, color: AppColor.gray2),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColor.gray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _saveAppliances(AppliancesController controller) {
    Get.back();
    Get.snackbar(
      'تم الحفظ',
      'تم حفظ ${controller.userAppliances.length} جهاز',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.green,
      colorText: AppColor.white,
    );
  }
}