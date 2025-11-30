// screens/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/controllers/budget_controller.dart';
import 'package:graduation_project/core/widgets/page_header.dart';

import '../controllers/bottom_navbar_controller.dart';
import '../core/widgets/bottom_navbar.dart';

class BudgetScreen extends StatelessWidget {
  BudgetScreen({super.key});

  final BudgetController controller = Get.put(BudgetController());
  final TextEditingController budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Column(
        children: [
          // الهيدر
          const PageHeader(title: "الميزانية الشهرية"),
          // محتوى الشاشة
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // الميزانية الحالية
                  Obx(() => controller.hasBudget.value
                      ? _buildCurrentBudgetCard()
                      : const SizedBox()),

                  const SizedBox(height: 30),

                  // قسم إدخال الميزانية
                  _buildBudgetInputSection(),

                  const SizedBox(height: 20),

                  // الاقتراحات
                  _buildBudgetSuggestions(),

                  const SizedBox(height: 30),

                  // زر الحفظ
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBudgetCard() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.primary_color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.primary_color, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppColor.primary_color,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                'ميزانيتك الحالية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '${controller.monthlyBudget.value} جنيه',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColor.primary_color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'شهرياً',
            style: TextStyle(
              fontSize: 16,
              color: AppColor.gray,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              budgetController.text = controller.monthlyBudget.value.toStringAsFixed(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: Icon(Icons.edit, color: AppColor.white, size: 18),
            label: Text(
              'تعديل الميزانية',
              style: TextStyle(
                color: AppColor.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildBudgetInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.gray2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حدد ميزانيتك الشهرية',
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
          const SizedBox(height: 20),

          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'أدخل المبلغ',
              hintStyle: TextStyle(color: AppColor.gray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.gray2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.gray2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.primary_color),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixText: 'جنيه',
              suffixStyle: TextStyle(
                color: AppColor.primary_color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 18,
              color: AppColor.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.gray2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقتراحات سريعة',
            style: TextStyle(
              fontSize: 18,
              color: AppColor.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSuggestionButton('٣٠٠ جنيه', 300.0),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSuggestionButton('٥٠٠ جنيه', 500.0),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSuggestionButton('٧٥٠ جنيه', 750.0),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSuggestionButton('١٠٠٠ جنيه', 1000.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionButton(String text, double value) {
    return ElevatedButton(
      onPressed: () {
        budgetController.text = value.toStringAsFixed(0);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary_color.withOpacity(0.1),
        foregroundColor: AppColor.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColor.primary_color),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : _saveBudget,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary_color,
          foregroundColor: AppColor.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: AppColor.gray2,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          controller.hasBudget.value ? 'تحديث الميزانية' : 'حفظ الميزانية',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));
  }

  void _saveBudget() {
    if (budgetController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال الميزانية',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
      );
      return;
    }

    controller.saveBudget(budget);
  }
}