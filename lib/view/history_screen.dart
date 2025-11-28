import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/history_controller.dart';

class HistoryScreen extends StatelessWidget {
  final controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("History"),
      actions: [
        ElevatedButton(onPressed: (){
          HistoryController().syncWithCloud();
          }, child: Icon(Icons.refresh))
      ],),
      body: Obx(() {
        if (controller.isLoading.value && controller.history.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.history.isEmpty) {
          return Center(child: Text("No history found"));
        }

        return ListView.builder(
          itemCount: controller.history.length,
          itemBuilder: (_, i) {
            final item = controller.history[i];
            return ListTile(
              title: Text("Price: ${item.price} EGP"),
              trailing: Text('${item.reading} Kw'),
              subtitle: Text(
                item.createdAt.toString().substring(0, 8),
              ),
            );
          },
        );
      }),
    );
  }
}
