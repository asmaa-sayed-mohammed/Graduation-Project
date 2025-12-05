import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/controllers/start_controller.dart';
import 'package:graduation_project/core/style/colors.dart';
import 'package:graduation_project/view/history_screen.dart';
import 'package:graduation_project/view/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/reading_controller.dart';
import '../core/widgets/page_header.dart';

class StartScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  final ReadingController reading_controller = Get.put(ReadingController());

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
                            "${controller.manualUsage.value > 0 ? controller.manualUsage.value.toStringAsFixed(3) : controller.latestUsageDifference.value} KWh",
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
                          "${controller.manualPrice.value > 0 ? controller.manualPrice.value.toStringAsFixed(2) : controller.currentPrice.value} EGP",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColor.primary_color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Obx(
                        () => Text(
                          " الشريحة ${controller.getCurrentTier()} ",
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

              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(35),
                  onTap: () async {
                    final user =
                        Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      Get.snackbar(
                        'خطأ',
                        'المستخدم غير مسجل الدخول',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    await reading_controller.saveReadingToHive(user.id);

                    Get.snackbar(
                      'تم الحفظ',
                      'تم حفظ القراءة محليا ',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.blueAccent,
                      colorText: Colors.white,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primary_color,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "حفظ القراءة",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              // Monthly Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerRight,
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

              // =================== BAR CHART ===================
              Padding(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width * 0.04,
                ),
                child: Obx(() {
                  final maxBarHeight =
                      MediaQuery.of(context).size.height * 0.45;
                  final containerHeight =
                      MediaQuery.of(context).size.height * 0.55;

                  return Container(
                    height: containerHeight,
                    padding: EdgeInsets.symmetric(
                      vertical: containerHeight * 0.02,
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
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.002,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        // ===== البارات =====
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(
                              controller.price12Months.length,
                              (i) {
                                double barHeight = controller.price12Months[i];
                                double calculatedHeight =
                                    (barHeight / controller.maxPriceValue()) *
                                    maxBarHeight;

                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                        0.01,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.08,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: containerHeight,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // السعر فوق البار
                                        Flexible(
                                          child: FittedBox(
                                            child: Text(
                                              "${barHeight.toStringAsFixed(0)} EGP",
                                              style: TextStyle(
                                                fontSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.03,
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.black,
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          height: containerHeight * 0.005,
                                        ),

                                        // البار نفسه
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.08,
                                            height: barHeight > 0
                                                ? calculatedHeight
                                                : 4,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                        ),

                                        SizedBox(
                                          height: containerHeight * 0.01,
                                        ),

                                        // اسم الشهر
                                        Flexible(
                                          child: FittedBox(
                                            child: Text(
                                              controller.months[i],
                                              style: TextStyle(
                                                fontSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.03,
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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
