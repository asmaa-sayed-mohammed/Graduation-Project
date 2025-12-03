// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_model_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingModelHiveAdapter extends TypeAdapter<ReadingModelHive> {
  @override
  final int typeId = 3;

  @override
  ReadingModelHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingModelHive(
      userId: fields[0] as String,
      difference_readings: fields[1] as double,
      price: fields[2] as double,
      chip: fields[3] as String,
      createdAt: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingModelHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.difference_readings)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.chip)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingModelHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
