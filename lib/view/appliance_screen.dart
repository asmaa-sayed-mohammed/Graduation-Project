import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appliances_controller.dart';
import '../models/appliance_model.dart';
import '../models/user_appliance_model.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';

class AppliancesScreen extends StatelessWidget {
  AppliancesScreen({super.key});
  final controller = Get.find<AppliancesController>();

  String getCategory(String name) {
    if (name.contains("تكييف") || name.contains("مكيف")) return "تكييف";
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
    final selectedCategory = "كل الأجهزة".obs;

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
              ),

              // زر إضافة جهاز غير موجود
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add, color: AppColor.black),
                  label: Text(
                    "أضف جهاز غير موجود",
                    style: TextStyle(
                        color: AppColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary_color,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    _showAddCustomDialog(context);
                  },
                ),
              ),

              // أزرار الفئات
              Obx(() {
                final grouped = <String, List<Appliance>>{};
                for (var a in controller.appliances) {
                  final cat = getCategory(a.name);
                  grouped.putIfAbsent(cat, () => []).add(a);
                }
                final customAppliances =
                controller.userAppliances.where((ua) => ua.applianceId == null).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      ...["كل الأجهزة", ...grouped.keys, if (customAppliances.isNotEmpty) "أجهزة مخصصة"]
                          .map(
                            (cat) => Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedCategory.value == cat
                                  ? AppColor.primary_color
                                  : AppColor.gray2,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => selectedCategory.value = cat,
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: AppColor.black,
                                fontWeight: selectedCategory.value == cat
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                );
              }),

              // قائمة الأجهزة
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final grouped = <String, List<Appliance>>{};
                  for (var a in controller.appliances) {
                    final cat = getCategory(a.name);
                    grouped.putIfAbsent(cat, () => []).add(a);
                  }
                  final customAppliances =
                  controller.userAppliances.where((ua) => ua.applianceId == null).toList();

                  if (controller.appliances.isEmpty && customAppliances.isEmpty) {
                    return Center(
                      child: Text("لا توجد أجهزة",
                          style: TextStyle(fontSize: 16, color: AppColor.black)),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    children: [
                      ...grouped.entries.map((entry) {
                        final category = entry.key;
                        final appliances = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedCategory.value == "كل الأجهزة" ||
                                selectedCategory.value == category)
                              ...[
                                Text(category,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.black)),
                                const SizedBox(height: 6),
                                ...appliances.map((appliance) {
                                  final userUa = controller.userAppliances.firstWhereOrNull(
                                          (ua) => ua.applianceId == appliance.id);
                                  final hours = (userUa?.hoursPerDay ?? 1.0).obs;
                                  final qty = (userUa?.quantity ?? 1).obs;
                                  final priority = (userUa?.priority ?? "important").obs;
                                  return _buildApplianceCard(
                                      appliance: appliance,
                                      userUa: userUa,
                                      hours: hours,
                                      qty: qty,
                                      priority: priority);
                                }).toList(),
                                const SizedBox(height: 12),
                              ]
                          ],
                        );
                      }).toList(),

                      // الأجهزة المخصصة
                      if (customAppliances.isNotEmpty &&
                          (selectedCategory.value == "كل الأجهزة" ||
                              selectedCategory.value == "أجهزة مخصصة"))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("أجهزة مخصصة",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.black)),
                            const SizedBox(height: 6),
                            ...customAppliances.map((ua) {
                              final hours = (ua.hoursPerDay).obs;
                              final qty = (ua.quantity).obs;
                              final priority = (ua.priority).obs;
                              return _buildApplianceCard(
                                  appliance: null,
                                  userUa: ua,
                                  hours: hours,
                                  qty: qty,
                                  priority: priority);
                            }).toList(),
                            const SizedBox(height: 12),
                          ],
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

  Widget _buildApplianceCard({
    Appliance? appliance,
    UserAppliance? userUa,
    required RxDouble hours,
    required RxInt qty,
    required RxString priority,
  }) {
    final controller = Get.find<AppliancesController>();

    return Card(
      color: AppColor.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appliance != null
                  ? "${appliance.name} (${appliance.brand}) - ${appliance.watt} وات"
                  : "${userUa?.customName} (${userUa?.customBrand}) - ${userUa?.customWatt} وات",
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.black),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.schedule, size: 20, color: AppColor.gray),
                const SizedBox(width: 6),
                Text("ساعات/يوم: ", style: TextStyle(color: AppColor.black)),
                SizedBox(
                  width: 60,
                  child: Obx(() => TextFormField(
                    initialValue: hours.value.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColor.white2,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) {
                      hours.value = double.tryParse(v) ?? 1.0;
                    },
                  )),
                ),
                const SizedBox(width: 16),
                Icon(Icons.confirmation_num, size: 20, color: AppColor.gray),
                const SizedBox(width: 6),
                Text("الكمية: ", style: TextStyle(color: AppColor.black)),
                SizedBox(
                  width: 50,
                  child: Obx(() => TextFormField(
                    initialValue: qty.value.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColor.white2,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) {
                      qty.value = int.tryParse(v) ?? 1;
                    },
                  )),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.flag, size: 20, color: AppColor.gray),
                const SizedBox(width: 6),
                Text("الأولوية: ", style: TextStyle(color: AppColor.black)),
                PriorityDropdown(priority: priority),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColor.red, size: 28),
                  onPressed: () {
                    if (userUa != null) controller.deleteUserAppliance(userUa);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (userUa != null) {
                    final updatedUa = userUa.copyWith(
                        hoursPerDay: hours.value, quantity: qty.value, priority: priority.value);
                    await controller.updateUserAppliance(updatedUa);
                    Get.snackbar("تم التحديث", "تم تحديث بيانات الجهاز بنجاح",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColor.white2,
                        colorText: AppColor.black);
                  } else if (appliance != null) {
                    await controller.addApplianceCustom(appliance,
                        hoursPerDay: hours.value, quantity: qty.value, priority: priority.value);
                    Get.snackbar("تم الإضافة", "تم إضافة الجهاز بنجاح",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColor.white2,
                        colorText: AppColor.black);
                  }
                },
                icon: Icon(userUa != null ? Icons.update : Icons.add, color: AppColor.black),
                label: Text(userUa != null ? "تحديث" : "أضف",
                    style: TextStyle(color: AppColor.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary_color,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==== Custom Appliance Dialog ====
  void _showAddCustomDialog(BuildContext context) {
    final controller = Get.find<AppliancesController>();
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nameCtrl = TextEditingController();
    final TextEditingController _brandCtrl = TextEditingController();
    final TextEditingController _wattCtrl = TextEditingController();
    final TextEditingController _hoursCtrl = TextEditingController(text: "1");
    final TextEditingController _qtyCtrl = TextEditingController(text: "1");
    String _priority = "not_important";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColor.white2,
        title: Text("أضف جهاز جديد",
            style: TextStyle(color: AppColor.black, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(_nameCtrl, "اسم الجهاز"),
                const SizedBox(height: 8),
                _buildField(_brandCtrl, "البراند"),
                const SizedBox(height: 8),
                _buildField(_wattCtrl, "الاستهلاك بالواط", isNumber: true),
                const SizedBox(height: 8),
                _buildField(_hoursCtrl, "عدد ساعات الاستخدام يوميًا", isNumber: true),
                const SizedBox(height: 8),
                _buildField(_qtyCtrl, "الكمية", isNumber: true),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("الأولوية: ", style: TextStyle(color: AppColor.black)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _priority,
                      items: const [
                        DropdownMenuItem(value: "important", child: Text("مهم")),
                        DropdownMenuItem(value: "not_important", child: Text("غير مهم")),
                      ],
                      onChanged: (v) {
                        if (v != null) _priority = v;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: TextStyle(color: AppColor.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await controller.addCustomAppliance(
                  name: _nameCtrl.text.trim(),
                  brand: _brandCtrl.text.trim(),
                  watt: int.parse(_wattCtrl.text.trim()),
                  hoursPerDay: double.parse(_hoursCtrl.text.trim()),
                  quantity: int.parse(_qtyCtrl.text.trim()),
                  priority: _priority,
                );
                Navigator.pop(context);
                Get.snackbar("تم الإضافة", "تم إضافة الجهاز بنجاح",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColor.white2,
                    colorText: AppColor.black);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary_color),
            child: Text("حفظ", style: TextStyle(color: AppColor.black)),
          ),
        ],
      ),
    );
  }

  TextFormField _buildField(TextEditingController ctrl, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) {
        if (v == null || v.isEmpty) return "يرجى ملء هذا الحقل";
        if (isNumber && double.tryParse(v) == null) return "أدخل قيمة صحيحة";
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColor.black),
        filled: true,
        fillColor: AppColor.white2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
    );
  }
}

class PriorityDropdown extends StatelessWidget {
  final RxString priority;
  const PriorityDropdown({required this.priority, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DropdownButton<String>(
        value: priority.value,
        dropdownColor: AppColor.white2,
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