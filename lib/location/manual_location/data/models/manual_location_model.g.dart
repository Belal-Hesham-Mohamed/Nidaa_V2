// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_location_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ManualLocationModelAdapter extends TypeAdapter<ManualLocationModel> {
  @override
  final int typeId = 1;

  @override
  ManualLocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ManualLocationModel(
      country: fields[0] as String?,
      city: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ManualLocationModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.country)
      ..writeByte(1)
      ..write(obj.city);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManualLocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
