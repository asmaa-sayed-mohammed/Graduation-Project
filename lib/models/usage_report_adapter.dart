import 'package:hive/hive.dart';
import '../models/history_model.dart';

class UsageRecordAdapter extends TypeAdapter<UsageRecord> {
  @override
  final int typeId = 0;

  @override
  UsageRecord read(BinaryReader reader) {
    return UsageRecord(
      userId: reader.readString(),
      reading: reader.readInt(),
      price: reader.readInt(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, UsageRecord obj) {
    writer.writeString(obj.userId);
    writer.writeInt(obj.reading);
    writer.writeInt(obj.price);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}
