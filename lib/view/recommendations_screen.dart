import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/budget_controller.dart';
import 'package:graduation_project/models/user_appliance_model.dart';
import '../controllers/smart_recommendation_controller.dart';
import '../controllers/appliances_controller.dart';
import '../core/widgets/page_header.dart';
import '../core/style/colors.dart';
import 'tips_screen.dart';
import '../view/budget_and_user_appliances_screen.dart';
import '../controllers/start_controller.dart';

class RecommendationsScreen extends StatelessWidget {
  RecommendationsScreen({super.key});
  final SmartRecommendationController controller = Get.put(SmartRecommendationController());
  final HomeController homeController = Get.find<HomeController>();
  final BudgetController budgetController = Get.put(BudgetController());
  final AppliancesController appliancesController = Get.find<AppliancesController>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.white2,
          body: Column(
            children: [
              PageHeader(
                title: "اقتراحات للتوفير",
                subtitle: "راجع استهلاكك واقتراحات التوفير",
                trailing: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: () {
                    controller.generateRecommendations();
                    Get.snackbar(
                      "تحديث",
                      "تم إعادة حساب التوصيات بناءً على الأجهزة المحدثة",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),
              Expanded(
                child: Obx(() {
                  double monthlyBudget = budgetController.monthlyBudget.value;
                  double monthlyCost = homeController.price12Months.isNotEmpty
                      ? homeController.price12Months.last
                      : 0.0;

                  if (controller.recommendations.isEmpty) {
                    return const Center(
                      child: Text(
                        "لا توجد توصيات حالياً",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final status = controller.recommendations.first;
                  final recs = controller.recommendations.length > 1
                      ? controller.recommendations[1]
                      : null;

                  // الكارد الرئيسي للتنبؤ
                  String message;
                  Color bgColor;
                  IconData icon;
                  double totalExpectedCost = status["totalExpectedCost"] ?? 0.0;

                  if (totalExpectedCost > monthlyBudget) {
                    message = " تنبيه: ستتجاوز الميزانية هذا الشهر! حاول تقليل استهلاكك.";
                    bgColor = Colors.red.shade100;
                    icon = Icons.warning_amber_rounded;
                  } else if ((totalExpectedCost - monthlyBudget).abs() < 1) {
                    message = " قريب من الحد: استهلاكك المتوقع يساوي الميزانية.";
                    bgColor = Colors.orange.shade100;
                    icon = Icons.error_outline;
                  } else {
                    message = " كل شيء جيد، استهلاكك المتوقع أقل من الميزانية.";
                    bgColor = Colors.green.shade100;
                    icon = Icons.check_circle_outline;
                  }

                  // مقارنة البودجيت مع التكلفة الشهرية
                  String budgetMessage;
                  Color budgetBgColor;
                  IconData budgetIcon;
                  bool showSuggestions = false;

                  if (monthlyCost > monthlyBudget) {
                    budgetMessage =
                        " لقد تجاوزت الميزانية! التكلفة الشهرية: ${monthlyCost.toStringAsFixed(2)} EGP  الميزانية: ${monthlyBudget.toStringAsFixed(2)} EGP. نصيحة: قلل ساعات الأجهزة غير المهمة أو زد الميزانية.";
                    budgetBgColor = Colors.red.shade100;
                    budgetIcon = Icons.warning_amber_rounded;
                    showSuggestions = true;
                  } else if ((monthlyBudget - monthlyCost) < monthlyBudget * 0.2) {
                    budgetMessage =
                        " قريب من تجاوز الميزانية! التكلفة الشهرية: ${monthlyCost.toStringAsFixed(2)} EGP (المتبقي: ${(monthlyBudget - monthlyCost).toStringAsFixed(2)} EGP). نصيحة: قلل ${recs?["changes"]?.first?["reduceHours"] ?? 1} ساعة يومياً لجهاز ${recs?["changes"]?.first?["device"] ?? "الأجهزة"}.";
                    budgetBgColor = Colors.orange.shade100;
                    budgetIcon = Icons.error_outline;
                    showSuggestions = true;
                  } else {
                    budgetMessage =
                        " الميزانية تمام! التكلفة الشهرية: ${monthlyCost.toStringAsFixed(2)} EGP  الميزانية: ${monthlyBudget.toStringAsFixed(2)} EGP. استمر كده.";
                    budgetBgColor = Colors.green.shade100;
                    budgetIcon = Icons.check_circle_outline;
                    showSuggestions = false;
                  }

                  // إنشاء قائمة Widgets
                  List<Widget> contentWidgets = [];

                  // كارد عرض التكلفة الشهرية والبادجت (مصقول بصرياً)
                  contentWidgets.add(
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColor.primary_color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          )
                        ],
                        border: Border.all(color: AppColor.primary_color.withOpacity(0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ملخص الميزانية الشهرية",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.primary_color),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "التكلفة الشهرية حتى الآن: ${monthlyCost.toStringAsFixed(2)} EGP",
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                          Text(
                            "الميزانية الشهرية: ${monthlyBudget.toStringAsFixed(2)} EGP",
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: monthlyBudget > 0 ? (monthlyCost / monthlyBudget).clamp(0, 1) : 0,
                              color: monthlyCost / (monthlyBudget > 0 ? monthlyBudget : 1) <= 0.5
                                  ? Colors.green
                                  : monthlyCost / (monthlyBudget > 0 ? monthlyBudget : 1) <= 0.8
                                      ? Colors.orange
                                      : Colors.red,
                              backgroundColor: Colors.grey.shade200,
                              minHeight: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  // كارد البودجيت + اقتراحات عند الاقتراب/التجاوز
                  contentWidgets.add(
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: budgetBgColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(budgetIcon, size: 36),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  budgetMessage,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (showSuggestions)
                        Obx(() {
                          final deviceSuggestions = controller.recommendations.length > 2
                              ? controller.recommendations[2]["changes"] ?? []
                              : [];

                          if (deviceSuggestions.isEmpty) {
                            return const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "اقتراحات لتحسين الميزانية:",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 12),
                                Text("• يُفضَّل زيادة الميزانية الشهرية بنسبة 10%."),
                                Text("• يُستحسن تقليل ساعات تشغيل الأجهزة غير المهمة."),
                                Text("• يُنصَح بتفعيل وضع توفير الطاقة."),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                " اقتراحات مخصصة لأجهزتك:",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              ...deviceSuggestions.map((device) {
                                final userDevice = appliancesController.userAppliances.firstWhere(
                                  (ua) => ua.name == device["device"] && ua.brand == device["brand"],
                                  orElse: () => UserAppliance(name: device["device"], brand: device["brand"], hoursPerDay: 0, watt: 0, applianceId: -1),
                                );
                                final currentHours = userDevice?.hoursPerDay ?? 0;
                                final reducedHours = currentHours - (device["reduceHours"] ?? 0);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    "• قلل ساعات تشغيل ${device["device"]} (${device["brand"]}) من $currentHours إلى $reducedHours ساعة يومياً لتوفير ${device["savedEGP"]?.toStringAsFixed(2) ?? '0.00'} EGP.",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              if (deviceSuggestions.length > 3)
                                const Text("• وكذلك للأجهزة الأخرى غير المهمة..."),
                              const SizedBox(height: 8),
                              const Text("• يُفضَّل زيادة الميزانية الشهرية بنسبة 10%."),
                              const Text("• يُنصَح بتفعيل وضع توفير الطاقة."),
                            ],
                          );
                        }),

                        ],
                      ),
                    ),
                  );

                  // قسم: أجهزتي المضافة (عرض سريع مع زر للانتقال لشاشة الإدارة)
                  contentWidgets.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'أجهزتي المضافة',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            if (appliancesController.isLoading.value) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (appliancesController.userAppliances.isEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text('لم تضف أي جهاز بعد.'),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Get.to(() => BudgetAndAppliancesScreen()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.primary_color,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: const Text('أضف جهاز الآن', style: TextStyle(color: Colors.black)),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: appliancesController.userAppliances.map((ua) {
                                return Card(
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    leading: Icon(Icons.devices, color: AppColor.primary_color),
                                    title: Text('${ua.name} (${ua.brand})', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text('ساعات/يوم: ${ua.hoursPerDay} • كمية: ${ua.quantity}', style: const TextStyle(color: Colors.black54)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.black54),
                                      onPressed: () => Get.to(() => BudgetAndAppliancesScreen()),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );

                  // الكارد الرئيسي للتوصيات العامة
                  contentWidgets.add(
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(icon, size: 36),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                                Text("الاستهلاك حتى اليوم: ${status["usedKwh"]?.toStringAsFixed(2) ?? 0} kWh"),
                                Text("تكلفة الاستهلاك حتى اليوم: ${status["usedCost"]?.toStringAsFixed(2) ?? 0} EGP"),
                                Text("التكلفة المتوقعة لبقية الشهر: ${status["expectedRemainingCost"]?.toStringAsFixed(2) ?? 0} EGP"),
                                Text("إجمالي الاستهلاك المتوقع: ${status["totalExpectedCost"]?.toStringAsFixed(2) ?? 0} EGP"),
                                Text("البادجت الشهري: ${status["monthlyBudget"]?.toStringAsFixed(2) ?? 0} EGP"),
                              ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: totalExpectedCost / (monthlyBudget > 0 ? monthlyBudget : 1),
                              color: totalExpectedCost / monthlyBudget <= 0.5
                                  ? Colors.green
                                  : totalExpectedCost / monthlyBudget <= 0.8
                                      ? Colors.orange
                                      : Colors.red,
                              backgroundColor: Colors.grey.shade300,
                              minHeight: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  // إضافة توصيات الأجهزة (إن وجدت)
                  for (int i = 0; i < (recs?["changes"]?.length ?? 0); i++) {
                    final change = recs?["changes"]?[i];
                    contentWidgets.add(
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.devices,
                                  color: Colors.blueAccent, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "${change?["device"]} (${change?["brand"]})",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("خفض ${change?["reduceHours"]} ساعة/يوم"),
                                  Text(
                                    "${(change?["savedEGP"] as double?)?.toStringAsFixed(2)} EGP",
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // زر الانتقال للمزيد من التوصيات
                  contentWidgets.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.to(() => const TipsScreen()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary_color,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            "اضغط هنا للمزيد من التوصيات",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 40),
                    children: contentWidgets,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
