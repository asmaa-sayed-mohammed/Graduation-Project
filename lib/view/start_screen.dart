import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/home_controller.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/view/history_screen.dart';
import 'package:graduation_project/view/profile_screen.dart';
import '../core/widgets/page_header.dart';

class StartScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              PageHeader(
                title: "استهلاك الكهرباء",
                leading: IconButton(
                  icon: Icon(Icons.account_circle_sharp, size: 32, color: AppColor.black),
                  onPressed: () {
                    Get.to(() => ProfileScreen());
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Usage Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(
                        color: AppColor.black,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Obx(() => Center(
                        child: Text(
                          "${controller.latestUsageDifference.value} KWh",
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 14),

                    // Price Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColor.primary_color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Obx(() => Text(
                        "${controller.currentPrice.value} EGP",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      )),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Monthly Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "التكلفة الشهرية",
                    style: TextStyle(
                      color: AppColor.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Bar Chart
              Container(
                height: screenHeight * 0.55,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: controller.price12Months.length * 60,
                      child: BarChart(
                        BarChartData(
                          maxY: controller.maxPriceValue() + 50,
                          minY: 0,
                          alignment: BarChartAlignment.spaceAround,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            horizontalInterval: controller.priceStep(),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                interval: controller.priceStep(),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  int i = value.toInt();
                                  if (i < 0 || i >= controller.months.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      controller.months[i],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(
                            controller.price12Months.length,
                                (i) => BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: controller.price12Months[i],
                                  width: 30,
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColor.primary_color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
              ),

              const SizedBox(height: 20),

              // History Button
              SizedBox(
                width: 260,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary_color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => HistoryScreen());
                  },
                  child: Text(
                    "شاهد قراءاتك السابقة",
                    style: TextStyle(
                      color: AppColor.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
