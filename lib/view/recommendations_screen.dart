import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/smart_recommendation_controller.dart';
import '../controllers/appliances_controller.dart';
import '../controllers/budget_controller.dart';
import '../controllers/start_controller.dart';
import '../models/user_appliance_model.dart';
import '../view/budget_and_user_appliances_screen.dart';
import 'tips_screen.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';
import 'package:graduation_project/view/appliance_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late final SmartRecommendationController controller;
  late final HomeController homeController;
  late final BudgetController budgetController;
  late final AppliancesController appliancesController;

  Map<String, dynamic>? lastStatus;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SmartRecommendationController>();
    homeController = Get.find<HomeController>();
    budgetController = Get.find<BudgetController>();
    appliancesController = Get.find<AppliancesController>();

    ever(appliancesController.userAppliances, (_) {
      controller.generateRecommendations();
      _updateLastStatus();
    });

    ever(budgetController.monthlyBudget, (_) {
      controller.generateRecommendations();
      _updateLastStatus();
    });
  }

  void _updateLastStatus() {
    if (controller.recommendations.isNotEmpty) {
      lastStatus = controller.recommendations.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.white2,
          body: Obx(() {
            final hasRecommendations = controller.recommendations.isNotEmpty;
            final status = hasRecommendations ? controller.recommendations.first : null;
            final recs = (controller.recommendations.length > 1) ? controller.recommendations[1] : null;

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: [
                const PageHeader(
                  title: "التوصيات الذكية",
                  subtitle: "إدارة استهلاك الكهرباء بسهولة",
                ),
                const SizedBox(height: 16),

                if (hasRecommendations) _buildBudgetAlert(),
                const SizedBox(height: 20),

                if (hasRecommendations && status != null) _buildConsumptionSummary(status),
                const SizedBox(height: 20),

                if (recs != null && recs["changes"] != null && recs["changes"].isNotEmpty)
                  ..._buildDeviceSuggestions(controller, appliancesController),
                const SizedBox(height: 20),

                const Text('أجهزتي المضافة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Obx(() {
                  if (appliancesController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (appliancesController.userAppliances.isEmpty) {
                    return _buildEmptyDevicesWidgetWithUsage(lastStatus);
                  }

                  return Column(
                    children: appliancesController.userAppliances
                        .map((ua) => _buildApplianceCard(ua))
                        .toList(),
                  );
                }),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => Get.to(() => const TipsScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary_color,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    "اضغط هنا للمزيد من التوصيات",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ========================================
  // صندوق تحذير الميزانية
  // ========================================
  Widget _buildBudgetAlert() {
    final monthlyBudget = budgetController.monthlyBudget.value;
    final monthlyCost = homeController.price12Months.isNotEmpty
        ? homeController.price12Months.last
        : 0.0;

    String budgetMessage;
    Color budgetColor;
    IconData budgetIcon;

    if (monthlyBudget > 0) {
      if (monthlyCost > monthlyBudget) {
        budgetMessage =
        "⚠️ تجاوزت الميزانية الشهرية!\nالتكلفة: ${monthlyCost.toStringAsFixed(2)} EGP\nالميزانية: ${monthlyBudget.toStringAsFixed(2)} EGP \nقم بزيادة الميزانية أو تقليل استخدام أجهزتك الغير مهمة.";
        budgetColor = Colors.red.shade100;
        budgetIcon = Icons.warning_amber_rounded;
      } else if ((monthlyBudget - monthlyCost) < monthlyBudget * 0.2) {
        budgetMessage =
        "⚠️ اقتربت من تجاوز الميزانية\nالمتبقي: ${(monthlyBudget - monthlyCost).toStringAsFixed(2)} EGP \nقلل استهلاكك للحفاظ على الميزانية.";
        budgetColor = Colors.orange.shade100;
        budgetIcon = Icons.error_outline;
      } else {
        budgetMessage = "✅ وضع الميزانية ممتاز\nاستمر على هذا المعدل";
        budgetColor = Colors.green.shade100;
        budgetIcon = Icons.check_circle_outline;
      }
    } else {
      budgetMessage = "ℹ️ لم يتم تحديد ميزانية بعد";
      budgetColor = Colors.grey.shade200;
      budgetIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: budgetColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(budgetIcon, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              budgetMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // ملخص الاستهلاك
  // ========================================
  Widget _buildConsumptionSummary(Map<String, dynamic> status) {
    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColor.primary_color.withOpacity(0.4), width: 1.2),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ملخص الاستهلاك:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.primary_color)),
            const SizedBox(height: 12),
            _buildSummaryRow("الاستهلاك حتى اليوم", "${status["usedKwh"]?.toStringAsFixed(2) ?? 0} kWh", Icons.bolt),
            _buildSummaryRow("تكلفة الاستهلاك حتى اليوم", "${status["usedCost"]?.toStringAsFixed(2) ?? 0} EGP", Icons.attach_money),
            _buildSummaryRow("التكلفة المتوقعة لبقية الشهر", "${status["expectedRemainingCost"]?.toStringAsFixed(2) ?? 0} EGP", Icons.schedule),
            _buildSummaryRow("إجمالي الاستهلاك المتوقع", "${status["totalExpectedCost"]?.toStringAsFixed(2) ?? 0} EGP", Icons.bar_chart),
            _buildSummaryRow("الميزانية الشهرية", "${status["monthlyBudget"]?.toStringAsFixed(2) ?? 0} EGP", Icons.account_balance_wallet),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColor.primary_color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ========================================
  // اقتراحات تحسين استهلاك الأجهزة
  // ========================================
  List<Widget> _buildDeviceSuggestions(
      SmartRecommendationController controller,
      AppliancesController appliancesController) {

    final deviceSuggestions = controller.recommendations.length > 1
        ? List<Map<String, dynamic>>.from(controller.recommendations[1]["changes"] ?? [])
        : [];

    if (deviceSuggestions.isEmpty) {
      return [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueAccent, width: 1.2),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("💡 اقتراحات لتحسين ميزانيتك",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              SizedBox(height: 12),
              Text("• زيادة الميزانية الشهرية بنسبة 10% لتحسين التوازن.",
                  style: TextStyle(fontSize: 16, height: 1.4)),
              SizedBox(height: 8),
              Text("• تقليل ساعات تشغيل الأجهزة غير الضرورية.",
                  style: TextStyle(fontSize: 16, height: 1.4)),
              SizedBox(height: 8),
              Text("• تفعيل وضع توفير الطاقة في أكبر عدد من الأجهزة.",
                  style: TextStyle(fontSize: 16, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ];
    }

    return deviceSuggestions.map<Widget>((device) {
      final userDevice = appliancesController.userAppliances.firstWhere(
            (ua) => ua.name == device["device"] || ua.customName == device["device"],
        orElse: () => UserAppliance(
          name: device["device"] ?? 'Unknown',
          brand: device["brand"] ?? 'Unknown',
          hoursPerDay: 0,
          watt: 0,
          applianceId: -1,
        ),
      );

      final displayName = userDevice.customName?.isNotEmpty == true ? userDevice.customName! : userDevice.name;
      final displayBrand = userDevice.customBrand?.isNotEmpty == true ? userDevice.customBrand! : userDevice.brand;
      final currentHours = userDevice.hoursPerDay;
      final reducedHours = (currentHours - (device["reduceHours"] ?? 0)).clamp(0, currentHours);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: AppColor.primary_color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "قلل تشغيل جهاز $displayName ($displayBrand) من "
                    "$currentHours إلى $reducedHours ساعة يوميًا لتوفير "
                    "${device["savedEGP"]?.toStringAsFixed(2) ?? "0.00"} EGP.",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ========================================
  // بطاقة الأجهزة المضافة (محسنة UI)
  // ========================================
  Widget _buildApplianceCard(UserAppliance ua) {
    final displayName = ua.customName?.isNotEmpty == true ? ua.customName! : ua.name;
    final displayBrand = ua.customBrand?.isNotEmpty == true ? ua.customBrand! : ua.brand;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColor.primary_color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.devices, color: AppColor.primary_color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$displayName ($displayBrand)",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Row(
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
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColor.primary_color,
              onPressed: () => Get.to(() => BudgetAndAppliancesScreen()),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // صندوق الأجهزة الفارغ
  // ========================================
  Widget _buildEmptyDevicesWidgetWithUsage(Map<String, dynamic>? lastStatus) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.devices_other, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text("لم تضف أي جهاز بعد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (lastStatus != null)
            Text(
              "الاستهلاك حتى اليوم: ${lastStatus["usedKwh"]?.toStringAsFixed(2) ?? 0} kWh\n"
                  "بتكلفة: ${lastStatus["usedCost"]?.toStringAsFixed(2) ?? 0} EGP",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            )
          else
            const Text(
              "أضف أجهزتك الآن للحصول على توصيات دقيقة.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await Get.to(() => AppliancesScreen());
              controller.generateRecommendations();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary_color,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              "أضف أجهزتك للحصول على التوصيات",
              style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
