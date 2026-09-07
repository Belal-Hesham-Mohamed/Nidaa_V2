import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/prayer_times/data/datasource/prayer_times_local_datasource.dart';
import 'package:nidaa_v2/prayer_times/data/datasource/prayer_times_remote_datasource.dart';
import 'package:nidaa_v2/prayer_times/data/models/prayer_times_model.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/repositories/prayer_times_repo_base.dart';

class PrayerTimesRepo implements PrayerTimesRepoBase {
  final PrayerTimesRemoteDataSource remoteDataSource;
  final PrayerTimesLocalDataSource localDataSource;

  PrayerTimesRepo(this.remoteDataSource, this.localDataSource);

  List<DateTime> _getRequiredDates(DateTime today) {
    return List.generate(
      15,
      (index) => today.subtract(Duration(days: 7 - index)),
    );
  }

  Set<String> _getRequiredMonths(DateTime today) {
    final requiredDates = _getRequiredDates(today);
    return requiredDates.map((date) => '${date.year}-${date.month}').toSet();
  }

  Set<String> _getCachedMonths(List<PrayerTimesModel> savedPrayerTimes) {
    return savedPrayerTimes.map((prayerTime) {
      final date = _parseGregorianDate(prayerTime.date.gregorian);
      return '${date.year}-${date.month}';
    }).toSet();
  }

  DateTime _parseGregorianDate(String value) {
    final hyphenParts = value.split('-');
    if (hyphenParts.length == 3) {
      final day = int.tryParse(hyphenParts[0]);
      final month = int.tryParse(hyphenParts[1]);
      final year = int.tryParse(hyphenParts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    final readableMatch = RegExp(r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})$')
        .firstMatch(value);
    if (readableMatch != null) {
      final day = int.parse(readableMatch.group(1)!);
      final monthStr = readableMatch.group(2)!.toLowerCase();
      final year = int.parse(readableMatch.group(3)!);
      final month = _monthFromAbbrev(monthStr);
      if (month != null) return DateTime(year, month, day);
    }

    for (final pattern in ['dd MMM yyyy', 'd MMM yyyy']) {
      try {
        return DateFormat(pattern, 'en').parseStrict(value);
      } catch (_) {}
    }

    throw FormatException('Invalid gregorian date: $value');
  }

  int? _monthFromAbbrev(String abbrev) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    return months[abbrev];
  }

  Set<String> _getMissingMonths(
    Set<String> requiredMonths,
    Set<String> cachedMonths,
  ) {
    return requiredMonths.difference(cachedMonths);
  }

  Future<List<PrayerTimesModel>> _fetchMissingMonths(
    Set<String> missingMonths, {
    required double latitude,
    required double longitude,
  }) async {
    final allPrayerTimes = <PrayerTimesModel>[];

    for (final monthKey in missingMonths) {
      final monthData = _parseMonthKey(monthKey);
      final prayerTimes = await remoteDataSource.getCalendarByCoordinates(
        latitude: latitude,
        longitude: longitude,
        month: monthData['month']!,
        year: monthData['year']!,
      );
      allPrayerTimes.addAll(prayerTimes);
    }

    return allPrayerTimes;
  }

  List<PrayerTimesModel> _mergePrayerTimes(
    List<PrayerTimesModel> cachedPrayerTimes,
    List<PrayerTimesModel> newPrayerTimes,
  ) {
    final merged = <PrayerTimesModel>[...cachedPrayerTimes, ...newPrayerTimes];
    final uniquePrayerTimes = <String, PrayerTimesModel>{};

    for (final prayerTime in merged) {
      uniquePrayerTimes[prayerTime.date.gregorian] = prayerTime;
    }

    return uniquePrayerTimes.values.toList();
  }


  Map<String, int> _parseMonthKey(String monthKey) {
    final parts = monthKey.split('-');
    return {'year': int.parse(parts[0]), 'month': int.parse(parts[1])};
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> getPrayerTimesWithCacheByCoordinates({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final prayerTimes = await _getPrayerTimesWithCacheByCoordinates(
        today: today,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(prayerTimes.map(_toEntity).toList());
    } catch (_) {
      return Left(Failure('Something went wrong while getting prayer times'));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> replaceCacheByCoordinates({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final requiredMonths = _getRequiredMonths(today);
      final newPrayerTimes = await _fetchMissingMonths(
        requiredMonths,
        latitude: latitude,
        longitude: longitude,
      );
      await localDataSource.savePrayerTimes(newPrayerTimes);
      return Right(newPrayerTimes.map(_toEntity).toList());
    } catch (_) {
      return Left(
        Failure('Something went wrong while fetching new location prayer times'),
      );
    }
  }

  Future<List<PrayerTimesModel>> _getPrayerTimesWithCacheByCoordinates({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) async {
    final cachedPrayerTimes = await localDataSource.getSavedPrayerTimes() ?? [];
    final requiredMonths = _getRequiredMonths(today);
    final cachedMonths = _getCachedMonths(cachedPrayerTimes);
    final missingMonths = _getMissingMonths(requiredMonths, cachedMonths);

    List<PrayerTimesModel> mergedPrayerTimes = cachedPrayerTimes;

    if (missingMonths.isNotEmpty) {
      final newPrayerTimes = await _fetchMissingMonths(
        missingMonths,
        latitude: latitude,
        longitude: longitude,
      );

      mergedPrayerTimes = _mergePrayerTimes(cachedPrayerTimes, newPrayerTimes);
      await localDataSource.savePrayerTimes(mergedPrayerTimes);
    }

    final todayKey =
        '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';
    final todayIndex = mergedPrayerTimes.indexWhere(
      (pt) => pt.date.gregorian.trim() == todayKey,
    );

    if (todayIndex == -1 ||
        !_hasCompleteHijriData(mergedPrayerTimes[todayIndex].date)) {
      final todayTimings = await remoteDataSource.getTimingsByCoordinates(
        latitude: latitude,
        longitude: longitude,
        date: todayKey,
      );

      mergedPrayerTimes = _mergePrayerTimes(
        mergedPrayerTimes,
        [todayTimings],
      );

      await localDataSource.savePrayerTimes(mergedPrayerTimes);
    }

    return mergedPrayerTimes;
  }

  bool _hasCompleteHijriData(DateModel date) {
    return date.hijriDate?.trim().isNotEmpty == true &&
        date.hijriMonthEn?.trim().isNotEmpty == true &&
        date.hijriMonthAr?.trim().isNotEmpty == true &&
        date.hijriYear?.trim().isNotEmpty == true;
  }

  @override
  Future<Either<Failure, PrayerTimes>> getSavedPrayerTimes({
    required String date,
  }) async {
    try {
      final savedPrayerTimes = await localDataSource.getSavedPrayerTimes();
      if (savedPrayerTimes == null || savedPrayerTimes.isEmpty) {
        return Left(Failure('No saved prayer times'));
      }

      final savedDay = savedPrayerTimes.where(
        (prayerTime) => prayerTime.date.gregorian == date,
      );

      if (savedDay.isEmpty) {
        return Left(Failure('No saved prayer times for this date'));
      }

      return Right(_toEntity(savedDay.first));
    } catch (_) {
      return Left(
        Failure('Something went wrong while getting saved prayer times'),
      );
    }
  }

  @override
  Future<Either<Failure, PrayerTimes>> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    try {
      final prayerTimes = await remoteDataSource.getTimingsByCoordinates(
        latitude: latitude,
        longitude: longitude,
        date: date,
      );
      return Right(_toEntity(prayerTimes));
    } catch (_) {
      return Left(Failure('Something went wrong while getting prayer times'));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    try {
      final prayerTimes = await remoteDataSource.getCalendarByCoordinates(
        latitude: latitude,
        longitude: longitude,
        month: month,
        year: year,
      );
      await localDataSource.savePrayerTimes(prayerTimes);
      return Right(prayerTimes.map(_toEntity).toList());
    } catch (_) {
      return Left(Failure('Something went wrong while getting prayer times'));
    }
  }

  @override
  Future<Either<Failure, PrayerTimes>> getTimingsByCity({
    required String city,
    required String state,
    required String country,
    required String date,
  }) async {
    try {
      final prayerTimes = await _getTimingsByManualLocation(
        city: city,
        state: state,
        country: country,
        date: date,
      );
      return Right(_toEntity(prayerTimes));
    } catch (_) {
      return Left(Failure('Something went wrong while getting prayer times'));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCity({
    required String city,
    required String state,
    required String country,
    required int month,
    required int year,
  }) async {
    try {
      final prayerTimes = await _getCalendarByManualLocation(
        city: city,
        state: state,
        country: country,
        month: month,
        year: year,
      );
      await localDataSource.savePrayerTimes(prayerTimes);
      return Right(prayerTimes.map(_toEntity).toList());
    } catch (_) {
      return Left(Failure('Something went wrong while getting prayer times'));
    }
  }

  PrayerTimes _toEntity(PrayerTimesModel model) {
    final hijriDate = model.date.hijriDate?.trim() ?? '';
    final hijriDateParts = hijriDate.split('-');
    final hijriDay = hijriDateParts.length == 3
        ? hijriDateParts[0]
        : '';

    return PrayerTimes(
      timings: Timings(
        fajr: model.timings.fajr,
        sunrise: model.timings.sunrise,
        dhuhr: model.timings.dhuhr,
        asr: model.timings.asr,
        maghrib: model.timings.maghrib,
        isha: model.timings.isha,
      ),
      date: Date(
        gregorian: model.date.gregorian,
        hijriDay: hijriDay,
        hijriMonthEn: model.date.hijriMonthEn?.trim() ?? '',
        hijriMonthAr: model.date.hijriMonthAr?.trim() ?? '',
        hijriYear: model.date.hijriYear?.trim() ?? '',
      ),
      night: Night(
        midnight: model.night.midnight,
        firstThird: model.night.firstThird,
        lastThird: model.night.lastThird,
      ),
    );
  }

  Future<PrayerTimesModel> _getTimingsByManualLocation({
    required String city,
    required String state,
    required String country,
    required String date,
  }) async {
    try {
      return await remoteDataSource.getTimingsByCity(
        city: city,
        state: state,
        country: country,
        date: date,
      );
    } catch (_) {
      return remoteDataSource.getTimingsByAddress(
        state: state,
        country: country,
        date: date,
      );
    }
  }

  Future<List<PrayerTimesModel>> _getCalendarByManualLocation({
    required String city,
    required String state,
    required String country,
    required int month,
    required int year,
  }) async {
    try {
      return await remoteDataSource.getCalendarByCity(
        city: city,
        state: state,
        country: country,
        month: month,
        year: year,
      );
    } catch (_) {
      return remoteDataSource.getCalendarByAddress(
        state: state,
        country: country,
        month: month,
        year: year,
      );
    }
  }
}
