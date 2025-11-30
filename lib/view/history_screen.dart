import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/history_controller.dart';
import '../core/style/colors.dart';
import '../core/widgets/page_header.dart';

class HistoryScreen extends StatelessWidget {
  final controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const PageHeader(title: "السجل"),
           SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.history.isEmpty) {
                return  Center(child: CircularProgressIndicator());
              }

              if (controller.history.isEmpty) {
                return Center(child: Text("لا يوجد سجل"));
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
                      title: Text("السعر: ${item.price} جنية"),
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
          ),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary_color),onPressed: (){controller.syncWithCloud();
          },  child:Text('تحديث',style: TextStyle(color: AppColor.white),)),
          SizedBox(height: 40,)
        ],
      ),
    );
  }
}
