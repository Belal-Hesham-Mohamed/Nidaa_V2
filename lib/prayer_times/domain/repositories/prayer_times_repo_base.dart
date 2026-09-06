import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';

abstract class PrayerTimesRepoBase {
Future<Either<Failure, PrayerTimes>> getSavedPrayerTimes({
  required String date,
});
Future<Either<Failure, List<PrayerTimes>>> getPrayerTimesWithCacheByCoordinates({
  required DateTime today,
  required double latitude,
  required double longitude,
});
  Future<Either<Failure, PrayerTimes>> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  });

  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  });

  Future<Either<Failure, PrayerTimes>> getTimingsByCity({
    required String city,
    required String state,
    required String country,
    required String date,
  });

  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCity({
    required String city,
    required String state,
    required String country,
    required int month,
    required int year,
  });
}
