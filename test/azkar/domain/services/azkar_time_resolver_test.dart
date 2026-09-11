import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/azkar/domain/entities/azkar_entities.dart';
import 'package:nidaa_v2/azkar/domain/services/azkar_time_resolver.dart';

void main() {
  const resolver = AzkarTimeResolver();

  DateTime at(String time) {
    final parts = time.split(':');
    return DateTime(2026, 9, 11, int.parse(parts[0]), int.parse(parts[1]));
  }

  CurrentAzkarPeriod resolveAt(String time) {
    return resolver.resolve(
      fajr: '05:08',
      sunrise: '06:37',
      asr: '16:23',
      maghrib: '19:07',
      now: at(time),
    );
  }

  test('keeps Morning period after sunrise until Asr', () {
    expect(resolveAt('10:30'), CurrentAzkarPeriod.morning);
  });

  test('switches to Evening period at Asr and keeps it after Maghrib', () {
    expect(resolveAt('16:23'), CurrentAzkarPeriod.evening);
    expect(resolveAt('22:00'), CurrentAzkarPeriod.evening);
  });

  test('keeps Evening period before Fajr until Morning starts', () {
    expect(resolveAt('03:30'), CurrentAzkarPeriod.evening);
  });

  test('returns none only when the required prayer times are unavailable', () {
    expect(
      resolver.resolve(
        fajr: null,
        sunrise: '06:37',
        asr: '16:23',
        maghrib: '19:07',
        now: at('10:30'),
      ),
      CurrentAzkarPeriod.none,
    );
  });
}
