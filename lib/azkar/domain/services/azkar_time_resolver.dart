import 'package:nidaa_v2/azkar/domain/entities/azkar_entities.dart';

class AzkarTimeResolver {
  const AzkarTimeResolver();

  CurrentAzkarPeriod resolve({
    required String? fajr,
    required String? sunrise,
    required String? asr,
    required String? maghrib,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final fajrTime = _parse(fajr, current);
    final sunriseTime = _parse(sunrise, current);
    final asrTime = _parse(asr, current);
    final maghribTime = _parse(maghrib, current);
    if ([
      fajrTime,
      sunriseTime,
      asrTime,
      maghribTime,
    ].any((time) => time == null)) {
      return CurrentAzkarPeriod.none;
    }
    final validFajr = fajrTime;
    final validAsr = asrTime;
    final validMaghrib = maghribTime;
    if (!current.isBefore(validFajr!) && current.isBefore(validAsr!)) {
      return CurrentAzkarPeriod.morning;
    }
    if (_isBetween(current, validAsr!, validMaghrib!)) {
      return CurrentAzkarPeriod.evening;
    }
    return CurrentAzkarPeriod.none;
  }

  DateTime? _parse(String? value, DateTime base) {
    if (value == null || value.trim().isEmpty) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) return null;
    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  bool _isBetween(DateTime value, DateTime start, DateTime end) =>
      !value.isBefore(start) && value.isBefore(end);
}
