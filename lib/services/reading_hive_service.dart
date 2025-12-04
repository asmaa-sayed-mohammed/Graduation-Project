import 'package:hive/hive.dart';
import '../models/reading_model_hive.dart';

class ReadingHiveService {
  final Box<ReadingModelHive> readingBox;

  ReadingHiveService(this.readingBox);

  // حفظ القراءة في Hive فقط
  Future<void> saveReadings(ReadingModelHive reading) async {
    await readingBox.add(reading);
  }

  // تحميل كل القراءات
  List<ReadingModelHive> loadReadings() {
    return readingBox.values.toList();
  }

  // تحميل آخر قراءة
  ReadingModelHive? loadLastReading() {
    if (readingBox.isEmpty) return null;
    return readingBox.getAt(readingBox.length - 1);
  }
}
