import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appliances_controller.dart';
import '../models/user_appliance_model.dart';
import '../models/appliance_model.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';

class PriorityDropdown extends StatelessWidget {
  final RxString priority;
  const PriorityDropdown({required this.priority, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DropdownButton<String>(
        value: priority.value,
        dropdownColor: Colors.white,
        items: const [
          DropdownMenuItem(value: "important", child: Text("مهم")),
          DropdownMenuItem(value: "not_important", child: Text("غير مهم")),
        ],
        onChanged: (v) {
          if (v != null) priority.value = v;
        },
      );
    });
  }
}

class AppliancesScreen extends StatelessWidget {
  AppliancesScreen({super.key});
  final controller = Get.find<AppliancesController>();

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

  void _showAddCustomApplianceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final wattController = TextEditingController();
    final hoursController = TextEditingController(text: "1");
    final quantityController = TextEditingController(text: "1");
    final priority = "not_important".obs;

    Get.defaultDialog(
      title: "أضف جهاز غير موجود",
      titlePadding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            _buildInputField("اسم الجهاز", nameController),
            _buildInputField("النوع / الماركة", brandController),
            _buildInputField("القوة بالوات", wattController, keyboard: TextInputType.number),
            _buildInputField("ساعات/يوم", hoursController, keyboard: TextInputType.number),
            _buildInputField("الكمية", quantityController, keyboard: TextInputType.number),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                const Text("الأولوية: "),
                PriorityDropdown(priority: priority),
              ],
            ),
          ],
        ),
      ),
      buttonColor: AppColor.primary_color,
      textConfirm: "أضف",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      onConfirm: () async {
        final name = nameController.text.trim();
        final brand = brandController.text.trim();
        final watt = int.tryParse(wattController.text) ?? 0;
        final hours = double.tryParse(hoursController.text) ?? 1.0;
        final quantity = int.tryParse(quantityController.text) ?? 1;

        if (name.isEmpty || brand.isEmpty || watt <= 0) {
          Get.snackbar(
            "خطأ",
            "الرجاء ملء جميع الحقول بشكل صحيح",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        await controller.addCustomAppliance(
          name: name,
          brand: brand,
          watt: watt,
          hoursPerDay: hours,
          quantity: quantity,
          priority: priority.value,
        );

        Get.back();
        Get.snackbar(
          "تم الإضافة",
          "تم إضافة الجهاز بنجاح",
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        textDirection: TextDirection.rtl,
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final selectedCategory = "كل الأجهزة".obs;
    final int initialVisible = 3;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.white2,
          body: Column(
            children: [
              PageHeader(
                title: "كل الأجهزة",
                subtitle: "أضف أو حدث بيانات الأجهزة الخاصة بك",
                leading: IconButton(
                  icon: Icon(Icons.arrow_forward,
                      color: AppColor.black, size: 26),
                  onPressed: () {
                    controller.loadData();
                    Get.back();
                  },
                ),
              ),

              // زر إضافة جهاز جديد
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddCustomApplianceDialog(context),
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text(
                    "أضف جهاز جديد",
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary_color,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // قائمة الأجهزة
              Obx(() {
                if (controller.isLoading.value) {
                  return Expanded(
                    child: Center(child: CircularProgressIndicator(color: AppColor.primary_color,)),
                  );
                }

                if (controller.appliances.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text("لا توجد أجهزة",
                          style: TextStyle(fontSize: 16)),
                    ),
                  );
                }

                final Map<String, List<dynamic>> grouped = {};
                for (var a in controller.appliances) {
                  final cat = getCategory(a.name);
                  grouped.putIfAbsent(cat, () => []).add(a);
                }

                final categories = grouped.keys.toList();

                return Expanded(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            ...["كل الأجهزة", ...categories].map(
                                  (cat) => Obx(
                                    () => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      selectedCategory.value == cat
                                          ? AppColor.primary_color
                                          : Colors.grey.shade300,
                                    ),
                                    onPressed: () =>
                                    selectedCategory.value = cat,
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: selectedCategory.value == cat
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      Obx(() {
                        final filteredGroups = grouped.entries.where((e) =>
                        selectedCategory.value == "كل الأجهزة" ||
                            selectedCategory.value == e.key);

                        final list = filteredGroups.toList();

                        return Expanded(
                          child: ListView.builder(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final category = list[index].key;
                              final appliances = list[index].value;
                              final visibleCountRx = RxInt(
                                  (appliances.length < initialVisible)
                                      ? appliances.length
                                      : initialVisible);

                              return ExpansionTile(
                                initiallyExpanded: false,
                                title: Text(
                                  category,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  Obx(() {
                                    return Column(
                                      children: [
                                        ...List.generate(visibleCountRx.value,
                                                (i) {
                                              final appliance = appliances[i];
                                              final userUa = controller
                                                  .userAppliances
                                                  .firstWhereOrNull((ua) =>
                                              ua.applianceId ==
                                                  appliance.id);
                                              final hours = (userUa?.hoursPerDay ??
                                                  1.0)
                                                  .obs;
                                              final qty =
                                                  (userUa?.quantity ?? 1).obs;
                                              final priority = (userUa?.priority ??
                                                  "important")
                                                  .obs;

                                              return Card(
                                                color: Colors.white,
                                                elevation: 3,
                                                margin: const EdgeInsets.symmetric(
                                                    vertical: 6),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12),
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.all(12),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "${appliance.name} (${appliance.brand}) - ${appliance.watt} وات",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 10),

                                                      // ساعات + كمية
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.schedule,
                                                              size: 20,
                                                              color: Colors.grey),
                                                          const SizedBox(width: 6),
                                                          const Text("ساعات/يوم: "),
                                                          SizedBox(
                                                            width: 60,
                                                            child: Obx(() =>
                                                                TextFormField(
                                                                  initialValue: hours
                                                                      .value
                                                                      .toString(),
                                                                  keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center,
                                                                  decoration:
                                                                  InputDecoration(
                                                                    isDense: true,
                                                                    filled: true,
                                                                    fillColor:
                                                                    Colors.grey
                                                                        .shade100,
                                                                    contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                        6,
                                                                        horizontal:
                                                                        6),
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                                  ),
                                                                  onChanged:
                                                                      (v) {
                                                                    hours.value =
                                                                        double.tryParse(v) ??
                                                                            1.0;
                                                                  },
                                                                )),
                                                          ),
                                                          const SizedBox(width: 16),
                                                          const Icon(
                                                              Icons.confirmation_num,
                                                              size: 20,
                                                              color: Colors.grey),
                                                          const SizedBox(width: 6),
                                                          const Text("الكمية: "),
                                                          SizedBox(
                                                            width: 50,
                                                            child: Obx(() =>
                                                                TextFormField(
                                                                  initialValue:
                                                                  qty.value
                                                                      .toString(),
                                                                  keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center,
                                                                  decoration:
                                                                  InputDecoration(
                                                                    isDense: true,
                                                                    filled: true,
                                                                    fillColor:
                                                                    Colors.grey
                                                                        .shade100,
                                                                    contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                        6,
                                                                        horizontal:
                                                                        6),
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                                  ),
                                                                  onChanged:
                                                                      (v) {
                                                                    qty.value =
                                                                        int.tryParse(
                                                                            v) ??
                                                                            1;
                                                                  },
                                                                )),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 10),

                                                      // Priority + Delete
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.flag,
                                                              size: 20,
                                                              color: Colors.grey),
                                                          const SizedBox(width: 6),
                                                          const Text("الأولوية: "),
                                                          PriorityDropdown(
                                                              priority: priority),
                                                          const Spacer(),
                                                          // IconButton(
                                                          //   icon: const Icon(
                                                          //       Icons.delete,
                                                          //       color: Colors.red,
                                                          //       size: 28),
                                                          //   onPressed: () {
                                                          //     controller
                                                          //         .deleteUserAppliance(
                                                          //         userUa ??
                                                          //             UserAppliance(
                                                          //                 applianceId:
                                                          //                 appliance.id,
                                                          //                 name: appliance
                                                          //                     .name,
                                                          //                 brand: appliance
                                                          //                     .brand,
                                                          //                 watt: appliance
                                                          //                     .watt,
                                                          //                 hoursPerDay:
                                                          //                 1,
                                                          //                 quantity:
                                                          //                 1,
                                                          //                 priority:
                                                          //                 "important"));
                                                          //   },
                                                          // ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 10),

                                                      Align(
                                                        alignment:
                                                        Alignment.centerRight,
                                                        child:
                                                        ElevatedButton.icon(
                                                          onPressed: () async {
                                                            if (userUa != null) {
                                                              final updatedUa =
                                                              userUa.copyWith(
                                                                  hoursPerDay:
                                                                  hours.value,
                                                                  quantity:
                                                                  qty.value,
                                                                  priority:
                                                                  priority
                                                                      .value);
                                                              await controller
                                                                  .updateUserAppliance(
                                                                  updatedUa);
                                                              Get.snackbar(
                                                                  "تم التحديث",
                                                                  "تم تحديث بيانات الجهاز بنجاح",
                                                                  snackPosition:
                                                                  SnackPosition
                                                                      .BOTTOM);
                                                            } else {
                                                              await controller
                                                                  .addApplianceCustom(
                                                                  appliance,
                                                                  hoursPerDay:
                                                                  hours
                                                                      .value,
                                                                  quantity:
                                                                  qty.value,
                                                                  priority:
                                                                  priority
                                                                      .value);
                                                              Get.snackbar(
                                                                  "تم الإضافة",
                                                                  "تم إضافة الجهاز بنجاح",
                                                                  snackPosition:
                                                                  SnackPosition
                                                                      .BOTTOM);
                                                            }
                                                          },
                                                          icon: Icon(
                                                            userUa != null
                                                                ? Icons.update
                                                                : Icons.add,
                                                            color: Colors.black,
                                                          ),
                                                          label: Text(
                                                            userUa != null
                                                                ? "تحديث"
                                                                : "أضف",
                                                            style: const TextStyle(
                                                                color:
                                                                Colors.black),
                                                          ),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                            AppColor
                                                                .primary_color,
                                                            padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12,
                                                                horizontal: 20),
                                                            shape:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  12),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),

                                        if (visibleCountRx.value <
                                            appliances.length)
                                          TextButton(
                                            onPressed: () {
                                              final remaining =
                                                  appliances.length -
                                                      visibleCountRx.value;
                                              visibleCountRx.value +=
                                              (remaining >= 3)
                                                  ? 3
                                                  : remaining;
                                            },
                                            child: const Text(
                                              "عرض المزيد",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
