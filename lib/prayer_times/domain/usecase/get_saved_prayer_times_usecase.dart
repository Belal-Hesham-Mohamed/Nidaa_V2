import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/repositories/prayer_times_repo_base.dart';

class GetSavedPrayerTimesUsecase {
  final PrayerTimesRepoBase _prayerTimesRepository;

  GetSavedPrayerTimesUsecase(this._prayerTimesRepository);

Future<Either<Failure, PrayerTimes>> call({
  required String date,
}) async {
  return await _prayerTimesRepository.getSavedPrayerTimes(
    date: date,
  );
}
}
