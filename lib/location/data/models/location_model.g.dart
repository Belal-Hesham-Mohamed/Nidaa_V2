// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

class LocationModelAdapter extends TypeAdapter<LocationModel> {
  @override
  final int typeId = 0;

  @override
  LocationModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };

    return LocationModel(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      city: fields[2] as String?,
      subLocality: fields[3] as String?,
      administrativeArea: fields[4] as String?,
      country: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.subLocality)
      ..writeByte(4)
      ..write(obj.administrativeArea)
      ..writeByte(5)
      ..write(obj.country);
  }
}
