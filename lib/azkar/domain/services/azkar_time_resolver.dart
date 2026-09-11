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
    final asrTime = _parse(asr, current);

    // The Home card is a period recommendation, not a strict validity
    // window. Keep showing one of the two daily collections until the next
    // collection becomes active instead of showing an empty state between
    // sunrise/maghrib and the next period.
    if (fajrTime == null || asrTime == null) {
      return CurrentAzkarPeriod.none;
    }

    if (current.isBefore(fajrTime)) {
      return CurrentAzkarPeriod.evening;
    }

    if (current.isBefore(asrTime)) {
      return CurrentAzkarPeriod.morning;
    }

    return CurrentAzkarPeriod.evening;
  }

  DateTime? _parse(String? value, DateTime base) {
    if (value == null || value.trim().isEmpty) return null;

    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value.trim());
    if (match == null) return null;

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }

    return DateTime(base.year, base.month, base.day, hour, minute);
  }
}
