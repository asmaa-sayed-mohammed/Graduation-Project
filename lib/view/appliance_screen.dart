import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appliances_controller.dart';
import '../models/user_appliance_model.dart';

class AppliancesScreen extends StatelessWidget {
  AppliancesScreen({super.key});

  final controller = Get.find<AppliancesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("كل الأجهزة")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.appliances.isEmpty) {
          return const Center(child: Text("لا توجد أجهزة"));
        }

        return ListView.builder(
          itemCount: controller.appliances.length,
          itemBuilder: (context, index) {
            final appliance = controller.appliances[index];

            // هل الجهاز مضاف مسبقاً؟
            final userUa = controller.userAppliances
                .firstWhereOrNull((ua) => ua.applianceId == appliance.id);

            double hours = userUa?.hoursPerDay ?? 1.0;
            int qty = userUa?.quantity ?? 1;
            String priority = userUa?.priority ?? "important";

            return Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${appliance.name} (${appliance.brand}) - ${appliance.watt} وات",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // ساعات/يوم - كمية - الأولوية
                    Row(
                      children: [
                        const Text("ساعات/يوم: "),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: hours.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                            hours = double.tryParse(v) ?? 1.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text("الكمية: "),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            initialValue: qty.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => qty = int.tryParse(v) ?? 1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: priority,
                          items: const [
                            DropdownMenuItem(
                                value: "important", child: Text("مهم")),
                            DropdownMenuItem(
                                value: "not_important", child: Text("غير مهم")),
                          ],
                          onChanged: (v) => priority = v!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (userUa != null) {
                            // الجهاز موجود مسبقًا -> تحديث
                            final updatedUa = userUa.copyWith(
                              hoursPerDay: hours,
                              quantity: qty,
                              priority: priority,
                            );
                            await controller.updateUserAppliance(updatedUa);
                          } else {
                            // الجهاز جديد -> إضافة
                            await controller.addApplianceCustom(
                              appliance,
                              hoursPerDay: hours,
                              quantity: qty,
                              priority: priority,
                            );
                          }
                        },
                        child: Text(userUa != null ? "تحديث" : "أضف"),
                      ),
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