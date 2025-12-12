import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project/view/main_screen.dart';

import '../controllers/bottom_navbar_controller.dart';
import '../controllers/history_controller.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final controller = Get.put(HistoryController());

  @override
  void initState() {
    super.initState();
    controller.syncWithCloud(); // تحميل آخر بيانات
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.white2,
        body: Column(
          children: [
            // Header
            PageHeader(
              title: "السجل",
              leading: IconButton(
                onPressed: () {Get.back();},
                icon: Icon(Icons.arrow_back, color: AppColor.black, size: 28),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Obx(() {
                // Loading indicator
                if (controller.isLoading.value &&
                    controller.displayedHistory.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primary_color,
                    ),
                  );
                }

                // Empty state
                if (controller.displayedHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history, size: 80, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "لا يوجد سجل حتى الآن",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // List of items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.displayedHistory.length,
                        itemBuilder: (_, index) {
                          final item = controller.displayedHistory[index];

                          return Card(
                            color: AppColor.white,
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon Circle
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColor.primary_color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.bolt,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // Text info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "السعر: ${item.price} جنية",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          "الاستهلاك: ${item.reading} Kw",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.createdAt
                                                  .toString()
                                                  .substring(0, 10),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Load More Button
                    if (controller.displayedHistory.length <
                        controller.fullHistory.length)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary_color,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => controller.loadMore(),
                          child: const Text(
                            "عرض المزيد",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                    // Sync button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary_color,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => controller.syncWithCloud(),
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        label: const Text(
                          'تحديث السجل',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
