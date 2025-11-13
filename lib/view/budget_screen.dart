import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/controllers/budget_controller.dart';

class BudgetScreen extends StatelessWidget {
  BudgetScreen({super.key});

  final BudgetController controller = Get.put(BudgetController());
  final TextEditingController budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.primary_color,
        title: Text(
          'الميزانية الشهرية',
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نص التوضيح
            Text(
              'حدد ميزانيتك الشهرية للكهرباء',
              style: TextStyle(
                fontSize: 18,
                color: AppColor.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سنساعدك على توفير الطاقة والمال بناءً على ميزانيتك',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.gray,
              ),
            ),
            const SizedBox(height: 30),

            // حقل إدخال الميزانية
            Container(
              decoration: BoxDecoration(
                color: AppColor.white2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.gray2),
              ),
              child: TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الميزانية الشهرية (جنيه)',
                  labelStyle: TextStyle(color: AppColor.black),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixText: 'جنيه',
                  suffixStyle: TextStyle(color: AppColor.black, fontWeight: FontWeight.bold),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // أمثلة للميزانيات
            Text(
              'اقتراحات:',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.gray,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildBudgetChip('٣٠٠ جنيه', 300.0),
                _buildBudgetChip('٥٠٠ جنيه', 500.0),
                _buildBudgetChip('٧٥٠ جنيه', 750.0),
                _buildBudgetChip('١٠٠٠ جنيه', 1000.0),
              ],
            ),
            const SizedBox(height: 30),

            // زر الحفظ
            Obx(() => controller.isLoading.value
                ? Center(
              child: CircularProgressIndicator(
                color: AppColor.primary_color,
              ),
            )
                : ElevatedButton(
              onPressed: () {
                _saveBudget();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary_color,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'حفظ الميزانية',
                style: TextStyle(
                  color: AppColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ),

            const SizedBox(height: 20),

            // عرض الميزانية الحالية إذا موجودة
            Obx(() => controller.hasBudget.value
                ? Column(
              children: [
                Divider(
                  color: AppColor.gray2,
                  thickness: 1,
                ),
                const SizedBox(height: 20),
                Text(
                  'ميزانيتك الحالية',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.primary_color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.primary_color),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: AppColor.primary_color,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.monthlyBudget.value} جنيه',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary_color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    budgetController.text = controller.monthlyBudget.value.toStringAsFixed(0);
                  },
                  child: Text(
                    'تعديل الميزانية',
                    style: TextStyle(
                      color: AppColor.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
                : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetChip(String text, double value) {
    return GestureDetector(
      onTap: () {
        budgetController.text = value.toStringAsFixed(0);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.primary_color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.primary_color),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColor.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _saveBudget() {
    if (budgetController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال الميزانية',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final budget = double.tryParse(budgetController.text);
    if (budget == null || budget <= 0) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال ميزانية صحيحة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    controller.saveBudget(budget);
  }
}