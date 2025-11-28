import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/history_model.dart';
import '../services/database/hive_service.dart';
import '../services/database/supabase_service.dart';

class HistoryController extends GetxController {
  final hive = HiveHistoryService();
  final supa = SupabaseHistoryService();

  final history = <UsageRecord>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    loadHistory();
    super.onInit();
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;

      // 1. بجيب الـ Local DB الأول
      final localData = hive.loadHistory();

      if (localData != null && localData.isNotEmpty) {
        // 2. لو فيه بيانات، اعرضها
        history.value = localData;

        print('from hive');

      } else {
        // 3. لو مفيش بيانات، هجيبها من السيرفر
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final cloudData = await supa.getHistory(userId);
        history.value = cloudData;

        // 4. خزن البيانات الجديدة في الـ Local DB
        await hive.saveHistory(cloudData);

        print('from cloud');
      }
    } catch (e) {
       Get.snackbar('loaded History', '$e');
      print("Error loading history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // دالة اختيارية للمزامنة اليدوية
  Future<void> syncWithCloud() async {
     try {
      isLoading.value = true;
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final cloudData = await supa.getHistory(userId);
      history.value = cloudData;
      await hive.saveHistory(cloudData);
      Get.snackbar("Success", "History synced with cloud.");
    } catch (e) {
      Get.snackbar("Error", "Failed to sync history.");
      print("Error syncing history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
