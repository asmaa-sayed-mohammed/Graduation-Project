import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/budget_controller.dart';
import '../controllers/appliances_controller.dart';
import '../models/user_appliance_model.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';
import 'appliance_screen.dart';

class BudgetAndAppliancesScreen extends StatelessWidget {
  BudgetAndAppliancesScreen({super.key});

  final BudgetController budgetController = Get.put(BudgetController());
  final AppliancesController appliancesController = Get.find<AppliancesController>();
  final TextEditingController budgetTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      budgetController.init(currentUser.id);
    } else {
      return const Scaffold(
        body: Center(child: Text("الرجاء تسجيل الدخول أولاً")),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.white2,
          body: Column(
            children: [
              PageHeader(
                title: "إدارة الأجهزة والميزانية",
                subtitle: "راجع ميزانيتك الشهرية وأجهزتك المضافة",
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        if (budgetController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        budgetTextController.text =
                            budgetController.monthlyBudget.value.toStringAsFixed(2);

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "الميزانية الشهرية الحالية (EGP):",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: budgetTextController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    hintText: "أدخل الميزانية الجديدة",
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 16),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final val =
                                      double.tryParse(budgetTextController.text);
                                      if (val != null && val >= 0) {
                                        await budgetController.saveBudget(val);
                                        Get.snackbar(
                                          "✅ تم الحفظ",
                                          "تم تحديث الميزانية الشهرية بنجاح",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green.shade100,
                                          colorText: Colors.black,
                                        );
                                      } else {
                                        Get.snackbar(
                                          "⚠️ خطأ",
                                          "الرجاء إدخال قيمة صحيحة أكبر أو تساوي صفر",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primary_color,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "حفظ الميزانية",
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                          SizedBox(width: 8),
                          Text(
                            "أجهزتي المضافة",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          SizedBox(width: 8),
                          Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => AppliancesScreen());
                          },
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text(
                            "أضف جهاز جديد",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary_color,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (appliancesController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (appliancesController.userAppliances.isEmpty) {
                          return const Center(
                            child: Text(
                              "لم تضف أي جهاز بعد. استخدم الزر أعلاه لإضافة أجهزة.",
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: appliancesController.userAppliances.length,
                          itemBuilder: (context, index) {
                            final ua = appliancesController.userAppliances[index];
                            final hours = RxDouble(ua.hoursPerDay);
                            final qty = RxInt(ua.quantity);
                            final priority = RxString(ua.priority);

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${ua.displayName} - ${ua.effectiveWatt} وات${ua.applianceId == null ? " (مخصص)" : ""}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Text("ساعات/يوم: ",
                                            style: TextStyle(fontSize: 16)),
                                        SizedBox(
                                          width: 70,
                                          child: Obx(() => TextFormField(
                                            initialValue: hours.value.toString(),
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 12),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12)),
                                              fillColor: Colors.grey.shade100,
                                              filled: true,
                                            ),
                                            onChanged: (v) =>
                                            hours.value = double.tryParse(v) ?? 0,
                                          )),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Text("الكمية: ",
                                            style: TextStyle(fontSize: 16)),
                                        SizedBox(
                                          width: 60,
                                          child: Obx(() => TextFormField(
                                            initialValue: qty.value.toString(),
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 12),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12)),
                                              fillColor: Colors.grey.shade100,
                                              filled: true,
                                            ),
                                            onChanged: (v) =>
                                            qty.value = int.tryParse(v) ?? 1,
                                          )),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Text("الأولوية: ",
                                            style: TextStyle(fontSize: 16)),
                                        Obx(() => DropdownButton<String>(
                                          value: priority.value,
                                          dropdownColor: Colors.white,
                                          items: const [
                                            DropdownMenuItem(
                                              value: "important",
                                              child: Text("مهم"),
                                            ),
                                            DropdownMenuItem(
                                              value: "not_important",
                                              child: Text("غير مهم"),
                                            ),
                                          ],
                                          onChanged: (v) {
                                            if (v != null) priority.value = v;
                                          },
                                        )),
                                        const Spacer(),
                                        IconButton(
                                          icon: Icon(Icons.save,
                                              color: AppColor.primary_color, size: 28),
                                          onPressed: () {
                                            final updatedUa = UserAppliance(
                                              id: ua.id,
                                              applianceId: ua.applianceId,
                                              name: ua.name,
                                              brand: ua.brand,
                                              watt: ua.watt,
                                              customName: ua.customName,
                                              customBrand: ua.customBrand,
                                              customWatt: ua.customWatt,
                                              hoursPerDay: hours.value,
                                              quantity: qty.value,
                                              priority: priority.value,
                                            );
                                            appliancesController.updateUserAppliance(updatedUa);
                                            Get.snackbar(
                                              "✅ تم الحفظ",
                                              "تم تحديث بيانات الجهاز بنجاح",
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: AppColor.green,
                                              colorText: AppColor.black,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: AppColor.red, size: 28),
                                          onPressed: () {
                                            appliancesController.deleteUserAppliance(ua);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}