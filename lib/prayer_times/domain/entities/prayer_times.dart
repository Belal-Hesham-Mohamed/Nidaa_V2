class PrayerTimes {
  final Timings timings;
  final Date date;
  final Night night;

  PrayerTimes({required this.timings, required this.date, required this.night});
}

class Timings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  Timings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
}

class Date {
  final String gregorian;
  final String hijriDay;
  final String hijriMonthEn;
  final String hijriMonthAr;
  final String hijriYear;

  Date({
    required this.gregorian,
    required this.hijriDay,
    required this.hijriMonthEn,
    required this.hijriMonthAr,
    required this.hijriYear,
  });
}

class Night {
  final String midnight;
  final String firstThird;
  final String lastThird;

  Night({
    required this.midnight,
    required this.firstThird,
    required this.lastThird,
  });
}
