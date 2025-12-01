import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/budget_controller.dart';

class BudgetScreen extends StatelessWidget {
  BudgetScreen({super.key});

  final BudgetController budgetController = Get.put(BudgetController());
  final TextEditingController budgetTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      budgetController.init(currentUser.id);
    } else {
      return const Scaffold(
        body: Center(child: Text("Please log in first")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل الميزانية الشهرية"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (budgetController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // تحديث TextField بالميزانية الحالية
        budgetTextController.text =
            budgetController.monthlyBudget.value.toStringAsFixed(2);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "الميزانية الشهرية الحالية (EGP):",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: budgetTextController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "أدخل الميزانية الجديدة",
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final val = double.tryParse(budgetTextController.text);
                  if (val != null && val >= 0) {
                    await budgetController.saveBudget(val);
                    Get.snackbar(
                      "تم الحفظ",
                      "تم تحديث الميزانية الشهرية",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } else {
                    Get.snackbar(
                      "خطأ",
                      "الرجاء إدخال قيمة صحيحة أكبر أو تساوي صفر",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: const Text("حفظ الميزانية"),
              ),
            ],
          ),
        );
      }),
    );
  }
}