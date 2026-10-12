import 'package:dartz/dartz.dart';
import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:geocoding/geocoding.dart';
import 'package:hijri_core/hijri_core.dart' as hijri;
import 'package:intl/intl.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/repositories/prayer_times_repo_base.dart';

/// Data-layer adapter around adhan_dart. The domain only receives its existing
/// PrayerTimes entities; no adhan_dart types cross this boundary.
class PrayerTimesRepo implements PrayerTimesRepoBase {
  PrayerTimesRepo({PrayerCalculationSettings? settings})
    : settings = settings ?? PrayerCalculationSettings.egypt();

  final PrayerCalculationSettings settings;
  bool _timeZonesInitialized = false;

  tz.Location _locationTimeZone(double latitude, double longitude) {
    if (!_timeZonesInitialized) {
      tzdata.initializeTimeZones();
      _timeZonesInitialized = true;
    }
    final name = tzmap.latLngToTimezoneString(latitude, longitude);
    return tz.getLocation(name);
  }

  Future<PrayerTimes> _calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    final zone = _locationTimeZone(latitude, longitude);
    final localDate = tz.TZDateTime(zone, date.year, date.month, date.day);
    final coordinates = adhan.Coordinates(latitude, longitude);
    final parameters = settings.toAdhanParameters(coordinates);
    final calculated = adhan.PrayerTimes(
      coordinates: coordinates,
      date: localDate,
      calculationParameters: parameters,
    );

    String format(DateTime value) =>
        DateFormat('HH:mm').format(tz.TZDateTime.from(value, zone));

    final sunset = calculated.maghrib;
    var nextFajr = calculated.fajr;
    if (!nextFajr.isAfter(sunset)) {
      nextFajr = nextFajr.add(const Duration(days: 1));
    }
    final nightLength = nextFajr.difference(sunset);
    final firstThird = sunset.add(
      Duration(seconds: nightLength.inSeconds ~/ 3),
    );
    final middle = sunset.add(Duration(seconds: nightLength.inSeconds ~/ 2));
    final lastThird = sunset.add(
      Duration(seconds: nightLength.inSeconds * 2 ~/ 3),
    );
    final hijriDate = hijri.toHijri(
      DateTime.utc(date.year, date.month, date.day),
    );
    const arabicMonths = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];

    return PrayerTimes(
      timings: Timings(
        fajr: format(calculated.fajr),
        sunrise: format(calculated.sunrise),
        dhuhr: format(calculated.dhuhr),
        asr: format(calculated.asr),
        maghrib: format(calculated.maghrib),
        isha: format(calculated.isha),
      ),
      date: Date(
        gregorian: DateFormat('dd-MM-yyyy').format(date),
        hijriDay: hijriDate?.hd.toString() ?? '',
        hijriMonthEn: hijriDate == null ? '' : hijri.hmLong[hijriDate.hm - 1],
        hijriMonthAr: hijriDate == null ? '' : arabicMonths[hijriDate.hm - 1],
        hijriYear: hijriDate?.hy.toString() ?? '',
      ),
      timeZoneId: zone.name,
      night: Night(
        midnight: format(middle),
        firstThird: format(firstThird),
        lastThird: format(lastThird),
      ),
    );
  }

  DateTime _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        final date = DateTime(year, month, day);
        if (date.year == year && date.month == month && date.day == day) {
          return date;
        }
      }
    }
    for (final pattern in ['dd-MM-yyyy', 'dd MMM yyyy', 'd MMM yyyy']) {
      try {
        return DateFormat(pattern, 'en').parseStrict(value);
      } catch (_) {}
    }
    throw FormatException('Invalid prayer date: $value');
  }

  Future<adhan.Coordinates> _coordinatesForCity({
    required String city,
    required String state,
    required String country,
  }) async {
    final address = [
      city,
      state,
      country,
    ].where((part) => part.trim().isNotEmpty).join(', ');
    final matches = await Geocoding().locationFromAddress(address);
    if (matches.isEmpty) {
      throw StateError('No coordinates found for $address');
    }
    final result = matches.first;
    return adhan.Coordinates(result.latitude, result.longitude);
  }

  Future<Either<Failure, PrayerTimes>> _safe(
    Future<PrayerTimes> Function() action,
  ) async {
    try {
      return Right(await action());
    } catch (error) {
      return Left(Failure('Unable to calculate prayer times: $error'));
    }
  }

  @override
  Future<Either<Failure, PrayerTimes>> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) => _safe(
    () => _calculate(
      latitude: latitude,
      longitude: longitude,
      date: _parseDate(date),
    ),
  );

  @override
  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    try {
      final days = DateTime(year, month + 1, 0).day;
      return Right(
        await Future.wait(
          List.generate(
            days,
            (day) => _calculate(
              latitude: latitude,
              longitude: longitude,
              date: DateTime(year, month, day + 1),
            ),
          ),
        ),
      );
    } catch (error) {
      return Left(Failure('Unable to calculate prayer calendar: $error'));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>>
  getPrayerTimesWithCacheByCoordinates({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final locationZone = _locationTimeZone(latitude, longitude);
      final localToday = tz.TZDateTime.now(locationZone);
      return Right(
        await Future.wait(
          List.generate(
            15,
            (index) => _calculate(
              latitude: latitude,
              longitude: longitude,
              date: DateTime(
                localToday.year,
                localToday.month,
                localToday.day,
              ).add(Duration(days: index - 7)),
            ),
          ),
        ),
      );
    } catch (error) {
      return Left(Failure('Unable to calculate prayer times: $error'));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> replaceCacheByCoordinates({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) => getPrayerTimesWithCacheByCoordinates(
    today: today,
    latitude: latitude,
    longitude: longitude,
  );

  @override
  Future<Either<Failure, PrayerTimes>> getTimingsByCity({
    required String city,
    required String state,
    required String country,
    required String date,
  }) async => _safe(() async {
    final coordinates = await _coordinatesForCity(
      city: city,
      state: state,
      country: country,
    );
    return _calculate(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      date: _parseDate(date),
    );
  });

  @override
  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCity({
    required String city,
    required String state,
    required String country,
    required int month,
    required int year,
  }) async {
    try {
      final coordinates = await _coordinatesForCity(
        city: city,
        state: state,
        country: country,
      );
      final days = DateTime(year, month + 1, 0).day;
      return Right(
        await Future.wait(
          List.generate(
            days,
            (day) => _calculate(
              latitude: coordinates.latitude,
              longitude: coordinates.longitude,
              date: DateTime(year, month, day + 1),
            ),
          ),
        ),
      );
    } catch (error) {
      return Left(Failure('Unable to calculate prayer calendar: $error'));
    }
  }

  @override
  Future<Either<Failure, PrayerTimes>> getSavedPrayerTimes({
    required String date,
  }) async =>
      Left(Failure('Prayer times are calculated locally and are not cached.'));
}

/// Preferences are persisted/configurable independently of the repository,
/// enabling later country-based defaults and user overrides.
class PrayerCalculationSettings {
  const PrayerCalculationSettings({
    required this.madhab,
    required this.highLatitudeRule,
  });

  factory PrayerCalculationSettings.egypt() => const PrayerCalculationSettings(
    madhab: adhan.Madhab.shafi,
    highLatitudeRule: null,
  );

  final adhan.Madhab madhab;
  final adhan.HighLatitudeRule? highLatitudeRule;

  adhan.CalculationParameters toAdhanParameters(
    adhan.Coordinates coordinates,
  ) => adhan.CalculationMethodParameters.egyptian()
    ..madhab = madhab
    ..highLatitudeRule =
        highLatitudeRule ?? adhan.HighLatitudeRule.recommended(coordinates);
}
