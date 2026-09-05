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

  @override
  Future<Either<Failure, List<PrayerTimes>>> getSavedPrayerTimes() async {
    try {
      final savedPrayerTimes =
          await localDataSource.getSavedPrayerTimes();

      if (savedPrayerTimes != null && savedPrayerTimes.isNotEmpty) {
        return Right(
          savedPrayerTimes.map(_toEntity).toList(),
        );
      }

      return Left(
        Failure('No saved prayer times'),
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