// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimesModelAdapter extends TypeAdapter<PrayerTimesModel> {
  @override
  final int typeId = 2;

  @override
  PrayerTimesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimesModel(
      timings: fields[0] as TimingsModel,
      date: fields[1] as DateModel,
      night: fields[2] as NightModel,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimesModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.timings)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.night);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimingsModelAdapter extends TypeAdapter<TimingsModel> {
  @override
  final int typeId = 3;

  @override
  TimingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimingsModel(
      fajr: fields[0] as String,
      dhuhr: fields[1] as String,
      asr: fields[2] as String,
      sunrise: fields[3] as String,
      maghrib: fields[4] as String,
      isha: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TimingsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.fajr)
      ..writeByte(1)
      ..write(obj.dhuhr)
      ..writeByte(2)
      ..write(obj.asr)
      ..writeByte(3)
      ..write(obj.sunrise)
      ..writeByte(4)
      ..write(obj.maghrib)
      ..writeByte(5)
      ..write(obj.isha);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DateModelAdapter extends TypeAdapter<DateModel> {
  @override
  final int typeId = 4;

  @override
  DateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DateModel(
      gregorian: fields[0] as String,
      hijri: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DateModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.gregorian)
      ..writeByte(1)
      ..write(obj.hijri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NightModelAdapter extends TypeAdapter<NightModel> {
  @override
  final int typeId = 5;

  @override
  NightModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NightModel(
      midnight: fields[0] as String,
      firstThird: fields[1] as String,
      lastThird: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NightModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.midnight)
      ..writeByte(1)
      ..write(obj.firstThird)
      ..writeByte(2)
      ..write(obj.lastThird);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NightModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
