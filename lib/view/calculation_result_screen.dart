import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/core/style/colors.dart';
import '../../core/widgets/page_header.dart';

class CalculationResultScreen extends StatelessWidget {
  final double oldReading;
  final double newReading;
  final double consumption;
  final double totalPrice;
  final String tier;

  const CalculationResultScreen({
    super.key,
    required this.oldReading,
    required this.newReading,
    required this.consumption,
    required this.totalPrice,
    required this.tier,
  });



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          children: [
            // ===== الهيدر القابل لإعادة الاستخدام =====
            const PageHeader(title: 'نتيجة الحساب'),
      
            // ===== محتوى الصفحة =====
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildItem("القراءة القديمة", oldReading.toString()),
                      _buildDivider(),
                      _buildItem("القراءة الجديدة", newReading.toString()),
                      _buildDivider(),
                      _buildItem("الاستهلاك (kWh)", consumption.toString()),
                      _buildDivider(),
                      _buildItem("الشريحة", tier),
                      _buildDivider(),
                      _buildItem("السعر النهائي (EGP)", totalPrice.toString()),
                      const SizedBox(height: 30),
      
                      // زر رجوع
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary_color,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: Text(
                            'رجوع',
                            style: TextStyle(
                              color: AppColor.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColor.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: AppColor.gray,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: AppColor.gray,
        thickness: 1,
      ),
    );
  }
}
