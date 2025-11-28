import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/history_controller.dart';
import '../core/style/colors.dart';

class HistoryScreen extends StatelessWidget {
  final controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColor.primary_color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(120),
                bottomRight: Radius.circular(120),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "السجل",
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // زرار التحديث
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    controller.syncWithCloud();
                  },
                  child:  Icon(Icons.refresh),
                )
              ],
            ),
          ),
           SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.history.isEmpty) {
                return  Center(child: CircularProgressIndicator());
              }

              if (controller.history.isEmpty) {
                return Center(child: Text("No history found"));
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.history.length,
                itemBuilder: (_, i) {
                  final item = controller.history[i];

                  return Container(
                    margin:EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text("Price: ${item.price} EGP"),
                      trailing: Text(
                        '${item.reading} Kw',
                        style: TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        item.createdAt.toString().substring(0, 10),
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
