import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/smart_recommendation_controller.dart';
import '../core/widgets/page_header.dart';
import '../core/style/colors.dart';
import 'main_screen.dart';
import 'tips_screen.dart';

class RecommendationsScreen extends StatelessWidget {
  RecommendationsScreen({super.key});
  final SmartRecommendationController controller = Get.put(SmartRecommendationController());

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
                  if (controller.recommendations.isEmpty) {
                    return const Center(
                      child: Text(
                        "لا توجد توصيات حالياً",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
        
                  final status = controller.recommendations.first;
                  final recs = controller.recommendations.length > 1 ? controller.recommendations[1] : null;
        
                  // تحديد الرسالة واللون
                  String message;
                  Color bgColor;
                  IconData icon;
        
                  double totalExpectedCost = status["totalExpectedCost"] ?? 0.0;
                  double monthlyBudget = status["monthlyBudget"] ?? 0.0;
        
                  if (totalExpectedCost > monthlyBudget) {
                    message = "⚠ تنبيه: ستتجاوز البادجت هذا الشهر! حاول تقليل استهلاكك.";
                    bgColor = Colors.red.shade100;
                    icon = Icons.warning_amber_rounded;
                  } else if ((totalExpectedCost - monthlyBudget).abs() < 1) {
                    message = "⚠ قريب من الحد: استهلاكك المتوقع يساوي البادجت.";
                    bgColor = Colors.orange.shade100;
                    icon = Icons.error_outline;
                  } else {
                    message = " كل شيء جيد، استهلاكك المتوقع أقل من البادجت.";
                    bgColor = Colors.green.shade100;
                    icon = Icons.check_circle_outline;
                  }
        
                  return Column(
                    children: [
                      // البطاقة الرئيسية
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
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      // قائمة التوصيات
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: (recs?["changes"]?.length ?? 0) + 1,
                          itemBuilder: (context, index) {
                            if (index == (recs?["changes"]?.length ?? 0)) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
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
                                ),
                              );
                            }
        
                            final change = recs?["changes"]?[index];
        
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.devices, color: Colors.blueAccent, size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "${change?["device"] ?? "-"} (${change?["brand"] ?? "-"})",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("خفض ${change?["reduceHours"] ?? 0} ساعة/يوم",
                                            style: const TextStyle(fontSize: 14)),
                                        Text("${(change?["savedEGP"] as double?)?.toStringAsFixed(2) ?? '0.00'} EGP",
                                            style: const TextStyle(fontSize: 14, color: Colors.green)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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