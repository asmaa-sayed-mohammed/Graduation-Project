import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/history_model.dart';
import '../services/database/hive_service.dart';
import '../services/database/supabase_service.dart';

class HistoryController extends GetxController {
  final hive = HiveHistoryService();
  final supa = SupabaseHistoryService();

  final fullHistory = <UsageRecord>[]; // كل البيانات كاملة
  final displayedHistory = <UsageRecord>[].obs; // المعروض على الشاشة
  final isLoading = true.obs;

  int limit = 5;
  int currentCount = 0;

  @override
  void onInit() {
    loadInitial();
    super.onInit();
  }

  Future<void> loadInitial() async {
    try {
      isLoading.value = true;

      final localData = hive.loadHistory();

      if (localData != null && localData.isNotEmpty) {
        fullHistory.clear();
        fullHistory.addAll(localData);

        displayedHistory.clear();
        displayedHistory.addAll(fullHistory.take(limit));

        currentCount = displayedHistory.length;

        print("Loaded from Hive");
      } else {
        await syncWithCloud();
      }
    } catch (e) {
      print("Load Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // زرار "عرض المزيد"
  void loadMore() {
    final remaining = fullHistory.length - currentCount;

    if (remaining <= 0) return; // مفيش حاجة تاني

    final nextBatch =
    fullHistory.skip(currentCount).take(limit).toList();

    displayedHistory.addAll(nextBatch);

    currentCount = displayedHistory.length;
  }

  // تحديث من السحابة
  Future<void> syncWithCloud() async {
    try {
      isLoading.value = true;

      final userId = Supabase.instance.client.auth.currentUser!.id;
      final cloudData = await supa.getHistory(userId);

      fullHistory.clear();
      fullHistory.addAll(cloudData);

      await hive.saveHistory(cloudData);

      displayedHistory.clear();
      displayedHistory.addAll(fullHistory.take(limit));

      currentCount = displayedHistory.length;

      print("Synced with Cloud");
    } catch (e) {
      print("Cloud Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
