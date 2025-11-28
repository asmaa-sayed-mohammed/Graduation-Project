import 'package:hive/hive.dart';
import '../../models/history_model.dart';

class HiveHistoryService {


  Future<void> saveHistory(List<UsageRecord> list) async {
    final box = Hive.box<UsageRecord>("history");

    //  نمسح البيانات القديمة قبل حفظ الجديدة لمنع التكرار
    await box.clear();

    // 3. نحول  list إلى map ليسهل حفظها
    final Map<dynamic, UsageRecord> map = {
      for (var i = 0; i < list.length; i++)
        i: list[i]};
    
    await box.putAll(map);
  }

  List<UsageRecord>? loadHistory() {
    final box = Hive.box<UsageRecord>("history");

    // Hive سيقوم بالتحويل تلقائياً بفضل الـ
    final data = box.values.toList();

    if (data.isEmpty) {
      return null;
    }

    return data;
  }
}
