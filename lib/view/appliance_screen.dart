import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/appliances_controller.dart';
import 'package:graduation_project/models/appliance_category_model.dart';
import 'package:graduation_project/models/appliance_model.dart';
import '../core/style/colors.dart';

class AppliancesScreen extends StatelessWidget {
  AppliancesScreen({super.key});

  final AppliancesController controller = Get.put(AppliancesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white2,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
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

  Widget _buildSelectionCounters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCounterItem(
            'المختارة',
            controller.selectedAppliancesCount.toString(),
            AppColor.primary_color,
          ),
          _buildCounterItem(
            'الإجمالي',
            controller.appliances.length.toString(),
            AppColor.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterItem(final String title, final String value, final Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              color: AppColor.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColor.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildCategorySection(),
        const SizedBox(height: 8),
        Expanded(child: _buildAppliancesList()),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, right: 8),
              child: Text(
                'الفئات',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            _buildCategoriesGrid(),
          ],
        ),
      );
    });
  }

  Widget _buildCategoriesGrid() {
    return Obx(() {
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8, // تقليل المسافة
          mainAxisSpacing: 8,  // تقليل المسافة
          childAspectRatio: 1.4, // تقليل الارتفاع
        ),
        itemCount: controller.categories.length,
        itemBuilder: (final BuildContext context, final int index) {
          final ApplianceCategory category = controller.categories[index];
          final bool isSelected = controller.selectedCategory.value?.id == category.id;
          return _buildCategoryItem(category, isSelected);
        },
      );
    });
  }

  Widget _buildCategoryItem(final ApplianceCategory category, final bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectCategory(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary_color : AppColor.white,
          borderRadius: BorderRadius.circular(15), // تقليل نصف القطر
          border: Border.all(
            color: isSelected ? AppColor.primary_color : AppColor.gray2.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category.nameAr),
              color: isSelected ? AppColor.white : AppColor.primary_color,
              size: 22, // تقليل حجم الأيقونة
            ),
            const SizedBox(height: 4), // تقليل المسافة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4), // تقليل الحشو
              child: Text(
                category.nameAr,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColor.white : AppColor.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 11, // تقليل حجم الخط
                  fontFamily: 'Tajawal',
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لإرجاع الأيقونة المناسبة لكل فئة
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'تكييف':
      case 'مكيفات':
      case 'تكييف هواء':
        return Icons.ac_unit;
      case 'إضاءة':
      case 'إنارة':
      case 'اضاءة':
        return Icons.lightbulb_outline;
      case 'مطبخ':
      case 'أجهزة مطبخ':
      case 'اجهزة مطبخ':
        return Icons.kitchen;
      case 'غسيل':
      case 'ملابس':
      case 'غسالة':
        return Icons.local_laundry_service;
      case 'تلفزيون':
      case 'ترفيه':
      case 'تلفاز':
        return Icons.tv;
      case 'كمبيوتر':
      case 'أجهزة مكتب':
      case 'حاسوب':
        return Icons.computer;
      case 'ثلاجة':
      case 'تبريد':
        return Icons.kitchen;
      case 'صحون':
      case 'غسالة صحون':
        return Icons.cleaning_services;
      case 'تدفئة':
      case 'سخان':
      case 'دفاية':
        return Icons.whatshot;
      case 'شاشات':
      case 'عرض':
        return Icons.desktop_windows;
      case 'مروحة':
      case 'مراوح':
        return Icons.air;
      case 'ميكروويف':
      case 'فرن':
        return Icons.microwave;
      case 'مكنسة':
      case 'مكنسة كهربائية':
        return Icons.cleaning_services;
      case 'سخان مياه':
      case 'سخان كهربائي':
        return Icons.water_damage;
      default:
        return Icons.devices_other;
    }
  }

  Widget _buildAppliancesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingIndicator();
      }

      if (controller.appliances.isEmpty) {
        return _buildEmptyState();
      }

      return Padding(
        padding: const EdgeInsets.all(12), // تقليل الحشو العام
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,  // تقليل المسافة
            mainAxisSpacing: 8,   // تقليل المسافة
            childAspectRatio: 0.75, // تقليل الارتفاع أكثر
          ),
          itemCount: controller.appliances.length,
          itemBuilder: (final BuildContext context, final int index) {
            final Appliance appliance = controller.appliances[index];
            return _buildApplianceCard(appliance);
          },
        ),
      );
    });
  }

  Widget _buildApplianceCard(final Appliance appliance) {
    final bool isSelected = controller.isApplianceSelected(appliance);

    return GestureDetector(
      onTap: () => controller.toggleApplianceSelection(appliance),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary_color : AppColor.white,
          borderRadius: BorderRadius.circular(12), // تقليل نصف القطر
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: isSelected ? AppColor.primary_color : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // تقليل الحشو
                  decoration: BoxDecoration(
                    color: isSelected ? _withOpacity(AppColor.white, 0.2) : _withOpacity(AppColor.primary_color, 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bolt,
                    color: isSelected ? AppColor.white : AppColor.primary_color,
                    size: 20, // تقليل حجم الأيقونة
                  ),
                ),
                const SizedBox(height: 6), // تقليل المسافة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4), // تقليل الحشو
                  child: Text(
                    appliance.nameAr,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? AppColor.white : AppColor.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 10, // تقليل حجم الخط
                      fontFamily: 'Tajawal',
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 3), // تقليل المسافة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // تقليل الحشو
                  decoration: BoxDecoration(
                    color: isSelected ? _withOpacity(AppColor.white, 0.2) : _withOpacity(AppColor.gray, 0.1),
                    borderRadius: BorderRadius.circular(6), // تقليل نصف القطر
                  ),
                  child: Text(
                    '${appliance.watt} واط',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: isSelected ? _withOpacity(AppColor.white, 0.9) : AppColor.black,
                      fontSize: 8, // تقليل حجم الخط
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 4, // تقليل المسافة
                right: 4, // تقليل المسافة
                child: Container(
                  padding: const EdgeInsets.all(3), // تقليل الحشو
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColor.primary_color,
                    size: 12, // تقليل حجم الأيقونة
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // دالة بديلة لـ withOpacity بدون تحذيرات
  Color _withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColor.primary_color,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الأجهزة...',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColor.black,
              fontSize: 14,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            color: AppColor.gray2,
            size: 60,
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد أجهزة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColor.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اختر فئة لعرض الأجهزة المتاحة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColor.black,
              fontSize: 12,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      if (controller.selectedAppliancesCount == 0) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: controller.isSaving.value ? null : controller.saveUserAppliances,
          backgroundColor: AppColor.primary_color,
          foregroundColor: AppColor.black,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          icon: controller.isSaving.value
              ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: AppColor.black,
              strokeWidth: 2,
            ),
          )
              : Icon(
            Icons.save_alt_rounded,
            color: AppColor.black,
            size: 20,
          ),
          label: Text(
            controller.isSaving.value
                ? 'جاري الحفظ...'
                : 'حفظ ${controller.selectedAppliancesCount} جهاز',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColor.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      );
    });
  }
}