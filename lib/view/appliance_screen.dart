import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appliances_controller.dart';
import '../models/user_appliance_model.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';

class AppliancesScreen extends StatelessWidget {
  AppliancesScreen({super.key});

  final controller = Get.find<AppliancesController>();

  // Helper to extract category from name
  String getCategory(String name) {
    if (name.contains("تكييف")) return "تكييف";
    if (name.contains("ثلاجة")) return "ثلاجات";
    if (name.contains("غسالة")) return "غسالات";
    if (name.contains("سخان")) return "سخانات كهرباء";
    if (name.contains("بوتاجاز") ||
        name.contains("ميكروويف") ||
        name.contains("فرن") ||
        name.contains("محمصة") ||
        name.contains("خلاط") ||
        name.contains("غلاية") ||
        name.contains("مكواة")) return "مطبخ";
    if (name.contains("مصباح") || name.contains("LED") || name.contains("فلورسنت"))
      return "إضاءة";
    if (name.contains("تلفزيون") ||
        name.contains("كمبيوتر") ||
        name.contains("لاب توب") ||
        name.contains("راوتر") ||
        name.contains("PlayStation") ||
        name.contains("Xbox") ||
        name.contains("Nintendo")) return "ترفيه وأجهزة إلكترونية";
    if (name.contains("مروحة")) return "مراوح وأجهزة صغيرة";
    return "أخرى";
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColor.white2,
        body: Column(
          children: [
            PageHeader(
              title: "كل الأجهزة",
              subtitle: "أضف أو حدث بيانات الأجهزة الخاصة بك",
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.appliances.isEmpty) {
                return const Expanded(
                    child: Center(
                        child: Text("لا توجد أجهزة",
                            style: TextStyle(fontSize: 16))));
              }

              // Group appliances by category
              final Map<String, List<dynamic>> grouped = {};
              for (var appliance in controller.appliances) {
                final cat = getCategory(appliance.name);
                grouped.putIfAbsent(cat, () => []).add(appliance);
              }

              final categories = grouped.keys.toList();
              final selectedCategory = RxString("كل الأجهزة");

              return Expanded(
                child: Column(
                  children: [
                    // شريط أزرار الفئات
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          ...["كل الأجهزة", ...categories].map(
                                (cat) => Obx(
                                  () => Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    selectedCategory.value == cat
                                        ? AppColor.primary_color
                                        : Colors.grey.shade300,
                                  ),
                                  onPressed: () => selectedCategory.value = cat,
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                        color: selectedCategory.value == cat
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ListView للأجهزة
                    Expanded(
                      child: Obx(() {
                        return ListView(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          children: grouped.entries
                              .where((entry) =>
                          selectedCategory.value == "كل الأجهزة" ||
                              selectedCategory.value == entry.key)
                              .map((entry) {
                            final category = entry.key;
                            final appliances = entry.value;

                            return ExpansionTile(
                              initiallyExpanded: true,
                              title: Text(
                                category,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              children: appliances.map((appliance) {
                                final userUa = controller.userAppliances
                                    .firstWhereOrNull(
                                        (ua) => ua.applianceId == appliance.id);

                                final hours = RxDouble(userUa?.hoursPerDay ?? 1.0);
                                final qty = RxInt(userUa?.quantity ?? 1);
                                final priority =
                                RxString(userUa?.priority ?? "important");

                                return Card(
                                  elevation: 2,
                                  margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${appliance.name} (${appliance.brand}) - ${appliance.watt} وات",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule,
                                                size: 20, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            const Text("ساعات/يوم: "),
                                            SizedBox(
                                              width: 60,
                                              child: Obx(() => TextFormField(
                                                initialValue:
                                                hours.value.toString(),
                                                keyboardType:
                                                TextInputType.number,
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6,
                                                      horizontal: 6),
                                                  border:
                                                  OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                                  ),
                                                  fillColor:
                                                  Colors.grey.shade100,
                                                  filled: true,
                                                ),
                                                onChanged: (v) =>
                                                hours.value =
                                                    double.tryParse(v) ??
                                                        1.0,
                                              )),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.confirmation_num,
                                                size: 20, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            const Text("الكمية: "),
                                            SizedBox(
                                              width: 50,
                                              child: Obx(() => TextFormField(
                                                initialValue: qty.value
                                                    .toString(),
                                                keyboardType:
                                                TextInputType.number,
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6,
                                                      horizontal: 6),
                                                  border:
                                                  OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                                  ),
                                                  fillColor:
                                                  Colors.grey.shade100,
                                                  filled: true,
                                                ),
                                                onChanged: (v) => qty.value =
                                                    int.tryParse(v) ?? 1,
                                              )),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.flag,
                                                size: 20, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            const Text("الأولوية: "),
                                            Obx(() => DropdownButton<String>(
                                              value: priority.value,
                                              items: const [
                                                DropdownMenuItem(
                                                    value: "important",
                                                    child: Text("مهم")),
                                                DropdownMenuItem(
                                                    value: "not_important",
                                                    child: Text("غير مهم")),
                                              ],
                                              onChanged: (v) {
                                                if (v != null)
                                                  priority.value = v;
                                              },
                                            )),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red, size: 28),
                                              onPressed: () {
                                                controller.deleteUserAppliance(
                                                    userUa ??
                                                        UserAppliance(
                                                          applianceId:
                                                          appliance.id,
                                                          name: appliance.name,
                                                          brand: appliance.brand,
                                                          watt: appliance.watt,
                                                          hoursPerDay: 1,
                                                          quantity: 1,
                                                          priority: "important",
                                                        ));
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              if (userUa != null) {
                                                final updatedUa = userUa.copyWith(
                                                    hoursPerDay: hours.value,
                                                    quantity: qty.value,
                                                    priority: priority.value);
                                                await controller
                                                    .updateUserAppliance(
                                                    updatedUa);
                                                Get.snackbar(
                                                    "تم التحديث",
                                                    "تم تحديث بيانات الجهاز بنجاح",
                                                    snackPosition:
                                                    SnackPosition.BOTTOM);
                                              } else {
                                                await controller.addApplianceCustom(
                                                    appliance,
                                                    hoursPerDay: hours.value,
                                                    quantity: qty.value,
                                                    priority: priority.value);
                                                Get.snackbar(
                                                    "تم الإضافة",
                                                    "تم إضافة الجهاز بنجاح",
                                                    snackPosition:
                                                    SnackPosition.BOTTOM);
                                              }
                                            },
                                            icon: Icon(userUa != null
                                                ? Icons.update
                                                : Icons.add),
                                            label: Text(
                                                userUa != null ? "تحديث" : "أضف"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColor.primary_color,
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 20),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}