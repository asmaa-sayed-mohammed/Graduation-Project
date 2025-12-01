import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/smart_recommendation_controller.dart';

class RecommendationsScreen extends StatelessWidget {
  RecommendationsScreen({super.key});

  final SmartRecommendationController controller =
  Get.put(SmartRecommendationController());

  @override
  Widget build(BuildContext context) {
    // توليد التوصيات عند البداية
    controller.generateRecommendations();

    return Scaffold(
      appBar: AppBar(
        title: const Text("توصيات استهلاك الكهرباء"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.generateRecommendations();
              Get.snackbar(
                "تحديث",
                "تم إعادة حساب التوصيات بناءً على الأجهزة المحدثة",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.recommendations.isEmpty) {
          return const Center(child: Text("لا توجد توصيات حالياً"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.recommendations.length,
          itemBuilder: (context, index) {
            final rec = controller.recommendations[index];

            // احصل على الأجهزة المقترح تقليلها مع حماية ضد null
            final changes =
                (rec["changes"] as List<Map<String, dynamic>>?) ?? [];

            final totalSaved =
                (rec["totalSavedEGP"] as double?) ?? 0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان التوصية
                    Text(
                      rec["title"] ?? "توصية",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),

                    // قائمة الأجهزة المقترح تقليلها
                    Column(
                      children: changes.map((c) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(c["device"] ?? "-",
                                      style: const TextStyle(fontSize: 16))),
                              Text(
                                  "خفض ${c["reduceHours"] ?? 0} ساعة/يوم",
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                  "${(c["savedEGP"] as double?)?.toStringAsFixed(2) ?? '0.00'} EGP",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.green)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const Divider(height: 20, thickness: 1),

                    // إجمالي التوفير
                    Text(
                      "إجمالي التوفير: ${totalSaved.toStringAsFixed(2)} EGP",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}