import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/prayer_times/data/datasource/prayer_times_local_datasource.dart';
import 'package:nidaa_v2/prayer_times/data/datasource/prayer_times_remote_datasource.dart';
import 'package:nidaa_v2/prayer_times/data/models/prayer_times_model.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/repositories/prayer_times_repo_base.dart';

class PrayerTimesRepo implements PrayerTimesRepoBase {
  final PrayerTimesRemoteDataSource remoteDataSource;
  final PrayerTimesLocalDataSource localDataSource;

  PrayerTimesRepo(
    this.remoteDataSource,
    this.localDataSource,
  );
  List<DateTime> _getRequiredDates(DateTime today) {
  return List.generate(
    15,
    (index) => today.subtract(
      Duration(days: 7 - index),
    ),
  );
}
Set<String> _getRequiredMonths(DateTime today) {
  final requiredDates = _getRequiredDates(today);

  return requiredDates
      .map((date) => '${date.year}-${date.month}')
      .toSet();
}
Set<String> _getCachedMonths(
  List<PrayerTimesModel> savedPrayerTimes,
) {
  return savedPrayerTimes.map((prayerTime) {
    final parts = prayerTime.date.gregorian.split('-');

    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    return '$year-$month';
  }).toSet();
}
Set<String> _getMissingMonths(
  Set<String> requiredMonths,
  Set<String> cachedMonths,
) {
  return requiredMonths.difference(cachedMonths);
}
Map<String, int> _parseMonthKey(String monthKey) {
  final parts = monthKey.split('-');

  return {
    'year': int.parse(parts[0]),
    'month': int.parse(parts[1]),
  };
}
Future<List<PrayerTimesModel>> _fetchMissingMonths(
  Set<String> missingMonths, {
  required double latitude,
  required double longitude,
}) async {
  final allPrayerTimes = <PrayerTimesModel>[];

  for (final monthKey in missingMonths) {
    final monthData = _parseMonthKey(monthKey);

    final prayerTimes =
        await remoteDataSource.getCalendarByCoordinates(
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
  final merged = <PrayerTimesModel>[
    ...cachedPrayerTimes,
    ...newPrayerTimes,
  ];

  final uniquePrayerTimes = <String, PrayerTimesModel>{};

  for (final prayerTime in merged) {
    uniquePrayerTimes[prayerTime.date.gregorian] = prayerTime;
  }

  return uniquePrayerTimes.values.toList();
}
Future<List<PrayerTimesModel>> _fetchMissingMonthsByCity(
  Set<String> missingMonths, {
  required String city,
  required String country,
}) async {
  final allPrayerTimes = <PrayerTimesModel>[];

  for (final monthKey in missingMonths) {
    final monthData = _parseMonthKey(monthKey);

    final prayerTimes =
        await remoteDataSource.getCalendarByCity(
      city: city,
      country: country,
      month: monthData['month']!,
      year: monthData['year']!,
    );

    allPrayerTimes.addAll(prayerTimes);
  }

  return allPrayerTimes;
}
Future<List<PrayerTimesModel>> _getPrayerTimesWithCacheByCoordinates({
  required DateTime today,
  required double latitude,
  required double longitude,
}) async {
  final cachedPrayerTimes =
      await localDataSource.getSavedPrayerTimes() ?? [];

  final requiredMonths = _getRequiredMonths(today);

  final cachedMonths = _getCachedMonths(cachedPrayerTimes);

  final missingMonths = _getMissingMonths(
    requiredMonths,
    cachedMonths,
  );

  if (missingMonths.isEmpty) {
    return cachedPrayerTimes;
  }

  final newPrayerTimes = await _fetchMissingMonths(
    missingMonths,
    latitude: latitude,
    longitude: longitude,
  );

  final mergedPrayerTimes = _mergePrayerTimes(
    cachedPrayerTimes,
    newPrayerTimes,
  );

  await localDataSource.savePrayerTimes(
    mergedPrayerTimes,
  );

  return mergedPrayerTimes;
}
  
 @override
Future<Either<Failure, PrayerTimes>> getSavedPrayerTimes({
  required String date,
}) async {
  try {
    final savedPrayerTimes =
        await localDataSource.getSavedPrayerTimes();

    if (savedPrayerTimes == null ||
        savedPrayerTimes.isEmpty) {
      return Left(
        Failure('No saved prayer times'),
      );
    }

    final savedDay = savedPrayerTimes.where(
      (prayerTime) => prayerTime.date.gregorian == date,
    );

    if (savedDay.isEmpty) {
      return Left(
        Failure('No saved prayer times for this date'),
      );
    }

    return Right(
      _toEntity(savedDay.first),
    );
  } catch (_) {
    return Left(
      Failure(
        'Something went wrong while getting saved prayer times',
      ),
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
      final prayerTimes =
          await remoteDataSource.getTimingsByCoordinates(
        latitude: latitude,
        longitude: longitude,
        date: date,
      );

      return Right(
        _toEntity(prayerTimes),
      );
    } catch (_) {
      return Left(
        Failure(
          'Something went wrong while getting prayer times',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>>
      getCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    try {
      final prayerTimes =
          await remoteDataSource.getCalendarByCoordinates(
        latitude: latitude,
        longitude: longitude,
        month: month,
        year: year,
      );

      await localDataSource.savePrayerTimes(
        prayerTimes,
      );

      return Right(
        prayerTimes.map(_toEntity).toList(),
      );
    } catch (_) {
      return Left(
        Failure(
          'Something went wrong while getting prayer times',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PrayerTimes>> getTimingsByCity({
    required String city,
    required String country,
    required String date,
  }) async {
    try {
      final prayerTimes =
          await remoteDataSource.getTimingsByCity(
        city: city,
        country: country,
        date: date,
      );

      return Right(
        _toEntity(prayerTimes),
      );
    } catch (_) {
      return Left(
        Failure(
          'Something went wrong while getting prayer times',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>>
      getCalendarByCity({
    required String city,
    required String country,
    required int month,
    required int year,
  }) async {
    try {
      final prayerTimes =
          await remoteDataSource.getCalendarByCity(
        city: city,
        country: country,
        month: month,
        year: year,
      );

      await localDataSource.savePrayerTimes(
        prayerTimes,
      );

      return Right(
        prayerTimes.map(_toEntity).toList(),
      );
    } catch (_) {
      return Left(
        Failure(
          'Something went wrong while getting prayer times',
        ),
      );
    }
  }

  PrayerTimes _toEntity(
    PrayerTimesModel model,
  ) {
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
        hijri: model.date.hijri,
      ),
      night: Night(
        midnight: model.night.midnight,
        firstThird: model.night.firstThird,
        lastThird: model.night.lastThird,
      ),
    );
  }
}