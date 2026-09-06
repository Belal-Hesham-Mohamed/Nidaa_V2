import 'package:hive/hive.dart';

part 'prayer_times_model.g.dart';

@HiveType(typeId: 2)
class PrayerTimesModel {
  PrayerTimesModel({
    required this.timings,
    required this.date,
    required this.night,
  });

  @HiveField(0)
  final TimingsModel timings;

  @HiveField(1)
  final DateModel date;

  @HiveField(2)
  final NightModel night;

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimesModel(
      timings: TimingsModel.fromJson(json['timings'] as Map<String, dynamic>),
      date: DateModel.fromJson(json['date'] as Map<String, dynamic>),
      night: NightModel.fromJson(json['timings'] as Map<String, dynamic>),
    );
  }
}

@HiveType(typeId: 3)
class TimingsModel {
  TimingsModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  @HiveField(0)
  final String fajr;

  @HiveField(1)
  final String sunrise;

  @HiveField(2)
  final String dhuhr;

  @HiveField(3)
  final String asr;

  @HiveField(4)
  final String maghrib;

  @HiveField(5)
  final String isha;

  factory TimingsModel.fromJson(Map<String, dynamic> json) {
    return TimingsModel(
      fajr: json['Fajr'] as String,
      sunrise: json['Sunrise'] as String,
      dhuhr: json['Dhuhr'] as String,
      asr: json['Asr'] as String,
      maghrib: json['Maghrib'] as String,
      isha: json['Isha'] as String,
    );
  }
}

@HiveType(typeId: 4)
class DateModel {
  DateModel({required this.gregorian, required this.hijri});

  @HiveField(0)
  final String gregorian;

  @HiveField(1)
  final String hijri;

  factory DateModel.fromJson(Map<String, dynamic> json) {
    final hijri = json['hijri'] as Map<String, dynamic>;
    final hijriMonth = hijri['month'] as Map<String, dynamic>;
    final gregorian = json['gregorian'] as Map<String, dynamic>;

    return DateModel(
      gregorian: gregorian['date'] as String,
      hijri: '${hijri['date']} ${hijriMonth['en']} ${hijri['year']}',
    );
  }
}

@HiveType(typeId: 5)
class NightModel {
  NightModel({
    required this.midnight,
    required this.firstThird,
    required this.lastThird,
  });

  @HiveField(0)
  final String midnight;

  @HiveField(1)
  final String firstThird;

  @HiveField(2)
  final String lastThird;

  factory NightModel.fromJson(Map<String, dynamic> json) {
    return NightModel(
      midnight: json['Midnight'] as String,
      firstThird: json['Firstthird'] as String,
      lastThird: json['Lastthird'] as String,
    );
  }
}
