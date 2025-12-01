import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/start_controller.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/view/history_screen.dart';
import 'package:graduation_project/view/profile_screen.dart';
import '../core/widgets/page_header.dart';

class StartScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
                  icon: Icon(
                    Icons.account_circle_sharp,
                    size: 32,
                    color: AppColor.black,
                  ),
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
                      child: Obx(
                        () => Center(
                          child: Text(
                            "${controller.latestUsageDifference.value} KWh",
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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
                      child: Obx(
                        () => Text(
                          "${controller.currentPrice.value} EGP",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
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
              // =================== BAR CHART ===================
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04), // بدل 15
                child: Obx(
                  () => Container(
                    height: screenHeight * 0.55,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02, // بدل 16
                    ),
                    child: Stack(
                      children: [
                        // ===== الشبكة الأفقية =====
                        Column(
                          children: List.generate(6, (index) {
                            return Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: screenWidth * 0.002, // بدل 1
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        // ===== البارات + الشبكة الرأسية + الخط الرأسي الأول =====
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // الخط الرأسي الأول قبل أول بار
                              Container(
                                width: screenWidth * 0.003, // بدل 1.5
                                height: double.infinity,
                                color: Colors.grey.shade300,
                              ),

                              // البارات والشبكة الرأسية لكل شهر
                              ...List.generate(controller.price12Months.length, (
                                i,
                              ) {
                                double barHeight = controller.price12Months[i];

                                return Stack(
                                  children: [
                                    // الخط الرأسي لكل شهر
                                    Container(
                                      width: screenWidth * 0.12, // بدل 50
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: screenWidth * 0.002,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // البار والرقم والشهر
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // السعر فوق البار
                                        Text(
                                          "${barHeight.toStringAsFixed(0)} EGP",
                                          style: TextStyle(
                                            fontSize:
                                                screenWidth * 0.03, // بدل 12
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.black,
                                          ),
                                        ),

                                        SizedBox(height: screenHeight * 0.005),

                                        // البار نفسه
                                        Container(
                                          width: screenWidth * 0.08, // بدل 35
                                          height:
                                              (barHeight /
                                                  controller.maxPriceValue()) *
                                              (screenHeight * 0.45),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColor.primary_color
                                                    .withOpacity(0.7),
                                                AppColor.primary_color,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: screenHeight * 0.01),

                                        // اسم الشهر
                                        Text(
                                          controller.months[i],
                                          style: TextStyle(
                                            fontSize:
                                                screenWidth * 0.03, // بدل 12
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

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
