import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/repositories/prayer_times_repo_base.dart';

class GetPrayerTimesWithCacheUsecase {
  final PrayerTimesRepoBase _prayerTimesRepository;

  GetPrayerTimesWithCacheUsecase(this._prayerTimesRepository);

  Future<Either<Failure, List<PrayerTimes>>> call({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) async {
    return await _prayerTimesRepository
        .getPrayerTimesWithCacheByCoordinates(
      today: today,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
