import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/prayer_times/data/repositories/prayer_times_repo.dart';

void main() {
  test('maps Egyptian Cairo calculation to existing domain timings', () async {
    final result = await PrayerTimesRepo().getTimingsByCoordinates(
      latitude: 30.0444,
      longitude: 31.2357,
      date: '12-10-2026',
    );
    final prayerTimes = result.fold(
      (failure) => fail(failure.message),
      (value) => value,
    );

    // AlAdhan method 5 / school 0 at these coordinates for 2026-10-12:
    // API returned 05:28, 06:55, 12:42, 16:00, 18:28, 19:45. The local
    // engine differs by +1 min for Dhuhr and -1 min for Asr (minute rounding).
    expect(prayerTimes.timings.fajr, '05:28');
    expect(prayerTimes.timings.sunrise, '06:55');
    expect(prayerTimes.timings.dhuhr, '12:43');
    expect(prayerTimes.timings.asr, '15:59');
    expect(prayerTimes.timings.maghrib, '18:28');
    expect(prayerTimes.timings.isha, '19:45');
    expect(prayerTimes.date.gregorian, '12-10-2026');
    expect(prayerTimes.timeZoneId, 'Africa/Cairo');
  });
}
