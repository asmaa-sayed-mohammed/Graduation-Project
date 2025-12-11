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

  final SmartRecommendationController controller =
  Get.put(SmartRecommendationController());
  final HomeController homeController = Get.find<HomeController>();
  final BudgetController budgetController = Get.find<BudgetController>();
  final AppliancesController appliancesController =
  Get.find<AppliancesController>();

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
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    controller.generateRecommendations();
                    Get.snackbar(
                      "تحديث",
                      "تم إعادة حساب التوصيات",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),
              Expanded(
                child: Obx(() {
                  final monthlyBudget = budgetController.monthlyBudget.value;
                  final monthlyCost = homeController.price12Months.isNotEmpty
                      ? homeController.price12Months.last
                      : 0.0;

                  final List<Widget> widgets = [];

                  // ================== كارد الميزانية ==================
                  late String budgetMessage;
                  late Color budgetColor;
                  late IconData budgetIcon;
                  bool showDeviceSuggestions = false;
                  bool showBudgetAdviceButton = false;

                  if (monthlyBudget > 0) {
                    if (monthlyCost > monthlyBudget) {
                      budgetMessage =
                      "تجاوزت الميزانية الشهرية!\nالتكلفة: ${monthlyCost.toStringAsFixed(2)} EGP\nالميزانية: ${monthlyBudget.toStringAsFixed(2)} EGP";
                      budgetColor = Colors.red.shade100;
                      budgetIcon = Icons.warning_amber_rounded;
                      showDeviceSuggestions = true;
                      showBudgetAdviceButton = true;
                    } else if ((monthlyBudget - monthlyCost) <
                        monthlyBudget * 0.2) {
                      budgetMessage =
                      "اقتربت من تجاوز الميزانية\nالمتبقي: ${(monthlyBudget - monthlyCost).toStringAsFixed(2)} EGP";
                      budgetColor = Colors.orange.shade100;
                      budgetIcon = Icons.error_outline;
                      showDeviceSuggestions = true;
                      showBudgetAdviceButton = true;
                    } else {
                      budgetMessage = "وضع الميزانية ممتاز\nاستمر على هذا المعدل";
                      budgetColor = Colors.green.shade100;
                      budgetIcon = Icons.check_circle_outline;
                    }
                  }

                  widgets.add(
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: budgetColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                        border: Border.all(
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(budgetIcon, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  budgetMessage,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                      height: 1.4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (showBudgetAdviceButton)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(() => BudgetAndAppliancesScreen());
                                },
                                icon: const Icon(Icons.tune,
                                    color: Colors.black),
                                label: const Text(
                                  "إدارة الميزانية والأجهزة",
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary_color,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );

                  // ================== التوقع الذكي ==================
                  if (controller.recommendations.isNotEmpty) {
                    final status = controller.recommendations.first;
                    final totalExpected = status["totalExpectedCost"] ?? 0.0;

                    widgets.add(
                      _predictionCard(
                        totalExpected,
                        monthlyBudget,
                        status,
                      ),
                    );
                  }

                  // ================== اقتراحات الأجهزة ==================
                  if (showDeviceSuggestions &&
                      controller.recommendations.length > 2) {
                    final deviceChanges =
                        controller.recommendations[2]["changes"] ?? [];

                    if (deviceChanges.isNotEmpty) {
                      widgets.add(_sectionTitle("اقتراحات مخصصة للأجهزة"));

                      widgets.addAll(deviceChanges.map<Widget>((change) {
                        return _deviceSuggestionTile(
                          change,
                          appliancesController.userAppliances,
                        );
                      }).toList());
                    }
                  }

                  // ================== أجهزتي المضافة (محسّنة) ==================
                  widgets.add(Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.devices_outlined, color: Colors.black54),
                        const SizedBox(width: 8),
                        const Text(
                          'أجهزتي المضافة',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ));

                  widgets.add(Obx(() {
                    if (appliancesController.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (appliancesController.userAppliances.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColor.primary_color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColor.primary_color.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: AppColor.primary_color.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'لم تضف أي جهاز حتى الآن',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'أضف أجهزتك لتحصل على توصيات شخصية لتوفير الطاقة',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => Get.to(() => BudgetAndAppliancesScreen()),
                                  icon: const Icon(Icons.add, color: Colors.black),
                                  label: const Text('أضف جهاز الآن', style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primary_color,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: appliancesController.userAppliances.map((ua) {
                          return _applianceCard(ua);
                        }).toList(),
                      ),
                    );
                  }));

                  // ================== زر نصائح عامة ==================
                  widgets.add(
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const TipsScreen()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary_color,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text(
                          "المزيد من النصائح",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  );

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 40),
                    children: widgets,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== UI HELPERS ==================

  Widget _predictionCard(
      double totalExpected, double budget, Map status) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.primary_color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.primary_color.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_outlined, color: AppColor.primary_color),
              const SizedBox(width: 8),
              Text(
                "التوقع الشهري",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.primary_color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "الإجمالي المتوقع: ${totalExpected.toStringAsFixed(2)} EGP",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: budget > 0 ? (totalExpected / budget).clamp(0, 1) : 0,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              color: totalExpected / (budget > 0 ? budget : 1) <= 0.5
                  ? Colors.green
                  : totalExpected / (budget > 0 ? budget : 1) <= 0.8
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _deviceSuggestionTile(
      Map change, List<UserAppliance> userAppliances) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.devices),
        title: Text("${change["device"]} (${change["brand"]})"),
        subtitle: Text("قلل ${change["reduceHours"]} ساعة / يوم"),
        trailing: Text(
          "${change["savedEGP"]?.toStringAsFixed(2)} EGP",
          style: const TextStyle(color: Colors.green),
        ),
      ),
    );
  }

  Widget _applianceCard(UserAppliance ua) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.primary_color.withOpacity(0.08)),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColor.primary_color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.devices, color: AppColor.primary_color, size: 24),
          ),
          title: Text(
            '${ua.name} (${ua.brand})',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${ua.hoursPerDay} ساعة/يوم',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'كمية: ${ua.quantity}',
                    style: const TextStyle(fontSize: 12, color: Colors.purple),
                  ),
                ),
              ],
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: AppColor.primary_color,
            onPressed: () => Get.to(() => BudgetAndAppliancesScreen()),
          ),
        ),
      ),
    );
  }
}
