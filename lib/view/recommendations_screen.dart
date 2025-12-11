import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/smart_recommendation_controller.dart';
import '../controllers/appliances_controller.dart';
import '../controllers/budget_controller.dart';
import '../controllers/start_controller.dart';
import '../models/user_appliance_model.dart';
import '../view/budget_and_user_appliances_screen.dart';
import 'appliance_screen.dart';
import 'tips_screen.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';

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

    // إعادة توليد التوصيات عند تغير الأجهزة أو الميزانية
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

                // **تنبيه الميزانية**
                if (hasRecommendations) _buildBudgetAlert(status!),
                const SizedBox(height: 20),

                // **ملخص الاستهلاك**
                if (hasRecommendations) _buildConsumptionSummary(status!),
                const SizedBox(height: 20),

                // **اقتراحات الأجهزة**
                if (recs != null && recs["changes"] != null && recs["changes"].isNotEmpty)
                  ..._buildDeviceSuggestions(controller, appliancesController),
                const SizedBox(height: 20),

                // **أجهزتي المضافة**
                const Text('أجهزتي المضافة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Obx(() {
                  if (appliancesController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (appliancesController.userAppliances.isEmpty) {
                    // لو ما فيش أجهزة، نعرض الاستهلاك السابق
                    return _buildEmptyDevicesWidgetWithUsage(lastStatus);
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appliancesController.userAppliances.length,
                    itemBuilder: (context, index) {
                      final ua = appliancesController.userAppliances[index];
                      final displayName = ua.customName?.isNotEmpty == true
                          ? ua.customName!
                          : ua.name;
                      final displayBrand = ua.customBrand?.isNotEmpty == true
                          ? ua.customBrand!
                          : ua.brand;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          leading: Icon(Icons.devices, color: AppColor.primary_color),
                          title: Text('$displayName ($displayBrand)',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              'ساعات/يوم: ${ua.hoursPerDay} • كمية: ${ua.quantity}',
                              style: const TextStyle(color: Colors.black54)),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black54),
                            onPressed: () => Get.to(() => BudgetAndAppliancesScreen()),
                          ),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 20),

                // **زر المزيد من التوصيات**
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
// بعد build() داخل _RecommendationsScreenState

  Widget _buildBudgetAlert(Map<String, dynamic> status) {
    double totalExpectedCost = status["totalExpectedCost"] ?? 0.0;
    double monthlyBudget = budgetController.monthlyBudget.value;

    String alertMessage;
    Color alertColor;
    IconData alertIcon;

    if (totalExpectedCost > monthlyBudget) {
      alertMessage = "⚠ ستتجاوز الميزانية هذا الشهر! حاول تقليل استهلاكك.";
      alertColor = Colors.red.shade100;
      alertIcon = Icons.warning_amber_rounded;
    } else if ((totalExpectedCost - monthlyBudget).abs() < 1) {
      alertMessage = "⚠ قريب من الحد: استهلاكك المتوقع يساوي الميزانية.";
      alertColor = Colors.orange.shade100;
      alertIcon = Icons.error_outline;
    } else {
      alertMessage = " كل شيء جيد، استهلاكك المتوقع أقل من الميزانية.";
      alertColor = Colors.green.shade100;
      alertIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alertIcon, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(alertMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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

  List<Widget> _buildDeviceSuggestions(SmartRecommendationController controller, AppliancesController appliancesController) {
    final deviceSuggestions = controller.recommendations.length > 1
        ? List<Map<String, dynamic>>.from(controller.recommendations[1]["changes"] ?? [])
        : [];

    if (deviceSuggestions.isEmpty) {
      return const [
        SizedBox(height: 12),
        Text("اقتراحات لتحسين الميزانية:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text("• يُفضَّل زيادة الميزانية الشهرية بنسبة 10%."),
        Text("• يُستحسن تقليل ساعات تشغيل الأجهزة غير المهمة."),
        Text("• يُنصَح بتفعيل وضع توفير الطاقة."),
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

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          "• قلل ساعات تشغيل $displayName ($displayBrand) من $currentHours إلى $reducedHours ساعة يومياً لتوفير ${device["savedEGP"]?.toStringAsFixed(2) ?? '0.00'} EGP.",
          style: const TextStyle(fontSize: 14),
        ),
      );
    }).toList();
  }

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

// باقي الـ Widgets ( _buildBudgetAlert, _buildConsumptionSummary, _buildDeviceSuggestions ) تظل كما هي
}
