import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/core/style/colors.dart';
import '../controllers/usage_controller.dart';

class UsageScreen extends StatelessWidget {
  final UsageController controller = Get.put(UsageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= HEADER ==================
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                color: AppColor.primary_color,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.menu, size: 30, color: AppColor.black),
                        Icon(Icons.notifications_none,
                            size: 30, color: AppColor.black),
                      ],
                    ),
                    SizedBox(height: 20),

                    Text(
                      "Electricity usage",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColor.black,
                      ),
                    ),
                    SizedBox(height: 15),

                    // usage box
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Obx(() => Text(
                                "${controller.currentUsage.value}KWh",
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.white,
                                ),
                              )),
                        ],
                      ),
                    ),

                    // cost bar
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.primary_color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(() => Text(
                            "${controller.currentPrice.value} EGP",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColor.black,
                            ),
                          )),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // =====================================================
              //                  MONTHLY CHART TITLE
              // =====================================================

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Monthly consumption",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // =====================================================
              //                  BAR CHART 12 MONTHS
              // =====================================================

              Container(
                height: 350,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index < 0 || index >= controller.months.length) {
                              return SizedBox.shrink();
                            }
                            return Text(
                              controller.months[index],
                              style: TextStyle(
                                color: AppColor.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),

                    barGroups: List.generate(controller.usage12Months.length, (i) {
                      return BarChartGroupData(
                        x: i, // index فقط
                        barRods: [
                          BarChartRodData(
                            toY: controller.usage12Months[i], // القيمة الحقيقية
                            width: 18,
                            color: AppColor.primary_color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // BUTTON
              Center(
                child: Container(
                  width: 260,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary_color,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      "See your readings",
                      style: TextStyle(
                        color: AppColor.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // =================== BOTTOM NAV ====================
      bottomNavigationBar: Container(
        height: 75,
        color: AppColor.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.home, color: AppColor.white, size: 30),
            Icon(Icons.bar_chart, color: AppColor.primary_color, size: 30),
            Icon(Icons.bolt, color: AppColor.white, size: 30),
            Icon(Icons.history, color: AppColor.white, size: 30),
          ],
        ),
      ),
    );
  }
}
