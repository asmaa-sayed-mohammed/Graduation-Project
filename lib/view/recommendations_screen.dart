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
                      budgetMessage = "وضع الميزانية ممتاز ✅\nاستمر على هذا المعدل";
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
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(budgetIcon, size: 34),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  budgetMessage,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (showBudgetAdviceButton)
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.to(() => BudgetAndAppliancesScreen());
                              },
                              icon: const Icon(Icons.settings,
                                  color: Colors.black),
                              label: const Text(
                                "قلل استهلاك اجهزتك / قم بزيادة الميزانية",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow.shade200,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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

                  // ================== أجهزتي ==================
                  widgets.add(const Divider(thickness: 2));
                  widgets.add(_sectionTitle("أجهزتي المضافة"));

                  widgets.add(Obx(() {
                    if (appliancesController.isLoading.value) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    if (appliancesController.userAppliances.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "لا توجد اجهزة",
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColor.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "اذهب لصفحة الميزانية لاضافة اجهزتك",
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColor.black,
                                ),
                          ),
                          const SizedBox(height: 8),
                          // ElevatedButton(
                          //   onPressed: () => Get.to(
                          //           () => BudgetAndAppliancesScreen()),
                          //   style: ElevatedButton.styleFrom(
                          //       backgroundColor: AppColor.primary_color),
                          //   child: const Text("أضف جهاز الآن",
                          //       style: TextStyle(color: Colors.black)),
                          // ),
                        ],
                      );
                    }

                    return Column(
                      children: appliancesController.userAppliances.map((ua) {
                        return _applianceCard(ua);
                      }).toList(),
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "التوقع الشهري",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("الإجمالي المتوقع: ${totalExpected.toStringAsFixed(2)} EGP"),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: budget > 0 ? (totalExpected / budget).clamp(0, 1) : 0,
            minHeight: 14,
            backgroundColor: Colors.grey.shade300,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.devices),
        title: Text("${ua.name} (${ua.brand})"),
        subtitle: Text("ساعات/يوم: ${ua.hoursPerDay}"),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => Get.to(() => BudgetAndAppliancesScreen()),
        ),
      ),
    );
  }
}
