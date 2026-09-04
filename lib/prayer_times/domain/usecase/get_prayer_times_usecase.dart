import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/repositories/prayer_times_repo_base.dart';

class GetPrayerTimesUsecase {
  final PrayerTimesRepoBase _prayerTimesRepository;

  GetPrayerTimesUsecase(this._prayerTimesRepository);

  Future<Either<Failure, PrayerTimes>> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    return await _prayerTimesRepository.getTimingsByCoordinates(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );
  }

  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    return await _prayerTimesRepository.getCalendarByCoordinates(
      latitude: latitude,
      longitude: longitude,
      month: month,
      year: year,
    );
  }

  Future<Either<Failure, PrayerTimes>> getTimingsByCity({
    required String city,
    required String country,
    required String date,
  }) async {
    return await _prayerTimesRepository.getTimingsByCity(
      city: city,
      country: country,
      date: date,
    );
  }

  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCity({
    required String city,
    required String country,
    required int month,
    required int year,
  }) async {
    return await _prayerTimesRepository.getCalendarByCity(
      city: city,
      country: country,
      month: month,
      year: year,
    );
  }
}
