// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileHiveAdapter extends TypeAdapter<ProfileHive> {
  @override
  final int typeId = 1;

  @override
  ProfileHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileHive(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as String,
      address: fields[3] as String?,
      companyName: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.companyName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProfileHiveAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}