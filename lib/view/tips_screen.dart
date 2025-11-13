import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/tips_controller.dart';
import 'package:graduation_project/core/style/colors.dart';

class TipsScreen extends StatelessWidget {
  TipsScreen({super.key});

  final TipsController controller = Get.put(TipsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.primary_color,
        title: Text(
          'نصائح التوفير الذكية',
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
          // فلتر الأولويات
          _buildPriorityFilter(),

          // قائمة النصائح
          Expanded(child: _buildTipsList()),
        ],
      ),
    );
  }

  Widget _buildPriorityFilter() {
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
            'تصفية النصائح',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPriorityChip('ALL', 'الكل'),
                _buildPriorityChip('HIGH', 'مهمة جداً'),
                _buildPriorityChip('MEDIUM', 'متوسطة'),
                _buildPriorityChip('LOW', 'مفيدة'),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority, String label) {
    final isSelected = controller.selectedPriority.value == priority;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColor.white : AppColor.black,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.filterByPriority(priority),
        backgroundColor: AppColor.white,
        selectedColor: controller.getPriorityColor(priority),
        side: BorderSide(
          color: isSelected ? controller.getPriorityColor(priority) : AppColor.gray2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTipsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.filteredTips.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredTips.length,
        itemBuilder: (context, index) {
          final tip = controller.filteredTips[index];
          return _buildTipCard(tip);
        },
      );
    });
  }

  Widget _buildTipCard(dynamic tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.getPriorityColor(tip.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.getPriorityText(tip.priority),
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColor.primary_color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tip.tipAr,
              style: TextStyle(
                color: AppColor.black,
                fontSize: 15,
                height: 1.6,
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
            'جاري تحميل النصائح...',
            style: TextStyle(
              color: AppColor.gray,
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
          Icon(Icons.lightbulb_outline, size: 64, color: AppColor.gray2),
          const SizedBox(height: 16),
          Text(
            'لا توجد نصائح متاحة',
            style: TextStyle(
              color: AppColor.gray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}