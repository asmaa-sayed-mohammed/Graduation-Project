import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/electricity_controller.dart';
import '../core/widgets/page_header.dart';


const Color primaryYellowColor = Color(0xFFFFCC00);

class CompanyScreen extends GetView<ElectricityController> {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var isArabic = controller.isArabicInput.value;
      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // استخدام الهيدر الموحد زي باقي الصفحات
                  PageHeader(
                    title: 'شركة الكهرباء',
                    subtitle: null,
                    leading: null,
                  ),
                  const SizedBox(height: 20),

                  // حقل البحث
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      controller: TextEditingController(text: controller.input.value)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.input.value.length),
                        ),
                      onChanged: controller.updateInput,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'أدخل اسم المنطقة أو المحافظة',
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.location_searching, color: Colors.black54),
                          onPressed: controller.getLocationAndFindCompany,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // زر البحث
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryYellowColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 80),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: controller.findCompany,
                    child: Text(
                       'ابحث عن الشركة',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // نتيجة البحث
                  Obx(() {
                    if (controller.loading.value) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (controller.companyName.value != null) {
                      final company = controller.companyName.value!;
                      final isValid = !company.contains('لم يتم العثور') && !company.contains('No company found');
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryYellowColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: primaryYellowColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              company,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            if (isValid)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: controller.openMap,
                                    icon: const Icon(Icons.map_outlined),
                                    label: Text('الخريطة' ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryYellowColor,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  ElevatedButton.icon(
                                    onPressed: controller.saveCurrentCompany,
                                    icon: const Icon(Icons.favorite),
                                    label: Text( 'حفظ' ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryYellowColor,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
