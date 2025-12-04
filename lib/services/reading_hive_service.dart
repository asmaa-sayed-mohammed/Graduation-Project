import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reading_model_hive.dart';

class ReadingHiveService {
  final Box<ReadingModelHive> readingBox;
  final SupabaseClient supabase = Supabase.instance.client;

  ReadingHiveService(this.readingBox);

  // حفظ القراءة محليًا في Hive دائمًا
  Future<void> saveReadings(ReadingModelHive reading) async {
    await readingBox.add(reading);

    // لو فيه نت، نزامن مباشرة مع Supabase
    if (await connected()) {
      try {
        await supabase.from('usage_record').insert(reading.toMap());
      } catch (e) {
        print('Sync failed for ${reading.userId}: $e');
      }
    }
  }

  // تحميل كل القراءات من Hive
  List<ReadingModelHive> loadReadings() {
    return readingBox.values.toList();
  }

  // تحميل آخر قراءة من Hive
  ReadingModelHive? loadLastReading() {
    if (readingBox.isEmpty) return null;
    return readingBox.getAt(readingBox.length - 1);
  }

  // التحقق من الاتصال بالانترنت
  Future<bool> connected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // مزامنة كل القراءات الموجودة في Hive مع Supabase
  Future<void> synchReadings() async {
    final readings = loadReadings();
    for (var reading in readings) {
      try {
        await supabase.from('usage_record').insert(reading.toMap());
      } catch (e) {
        print('Sync failed for ${reading.userId}: $e');
      }
    }
  }
}
