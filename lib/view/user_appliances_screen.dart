import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appliances_controller.dart';
import '../models/user_appliance_model.dart';

class UserAppliancesScreen extends StatelessWidget {
  UserAppliancesScreen({super.key});

  final AppliancesController controller = Get.find<AppliancesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("أجهزتي")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.userAppliances.isEmpty) {
          return const Center(child: Text("لم تضف أي جهاز بعد"));
        }

        return ListView.builder(
          itemCount: controller.userAppliances.length,
          itemBuilder: (context, index) {
            final ua = controller.userAppliances[index];

            double hours = ua.hoursPerDay;
            int qty = ua.quantity;
            String priority = ua.priority;

            return Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${ua.name} (${ua.brand}) - ${ua.watt} وات",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // ساعات/يوم
                    Row(
                      children: [
                        const Text("ساعات/يوم: "),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: hours.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final h = double.tryParse(v);
                              if (h != null && h >= 0) {
                                controller.updateUserAppliance(
                                  ua.copyWith(hoursPerDay: h),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // الكمية
                    Row(
                      children: [
                        const Text("الكمية: "),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            initialValue: qty.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final q = int.tryParse(v);
                              if (q != null && q >= 1) {
                                controller.updateUserAppliance(
                                  ua.copyWith(quantity: q),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // الأولوية
                    Row(
                      children: [
                        const Text("الأولوية: "),
                        DropdownButton<String>(
                          value: priority,
                          items: const [
                            DropdownMenuItem(
                                value: "important", child: Text("مهم")),
                            DropdownMenuItem(
                                value: "not_important",
                                child: Text("غير مهم")),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              controller.updateUserAppliance(
                                ua.copyWith(priority: v),
                              );
                            }
                          },
                        ),
                        const Spacer(),

                        // زر الحذف
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            controller.deleteUserAppliance(ua);
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
    );
  }
}