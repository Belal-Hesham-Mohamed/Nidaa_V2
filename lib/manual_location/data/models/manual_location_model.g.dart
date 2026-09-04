// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_location_model.dart';

class ManualLocationModelAdapter extends TypeAdapter<ManualLocationModel> {
  @override
  final int typeId = 1;

  @override
  ManualLocationModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
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
}
