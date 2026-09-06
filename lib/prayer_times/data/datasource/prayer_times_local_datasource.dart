import 'package:hive/hive.dart';
import 'package:nidaa_v2/prayer_times/data/models/prayer_times_model.dart';

abstract class PrayerTimesLocalDataSource {
  Future<void> savePrayerTimes(List<PrayerTimesModel> prayerTimes);
  Future<List<PrayerTimesModel>?> getSavedPrayerTimes();
  Future<void> deletePrayerTimes();
  Future<PrayerTimesModel?> getPrayerTimesForDate({
    required String date,
  });
}

class PrayerTimesLocalDataSourceImpl implements PrayerTimesLocalDataSource {
  final Box box;

  PrayerTimesLocalDataSourceImpl(this.box);

  @override
  Future<void> savePrayerTimes(
    List<PrayerTimesModel> prayerTimes,
  ) async {
    await box.put('prayer_times', prayerTimes);
  }

  @override
  Future<List<PrayerTimesModel>?> getSavedPrayerTimes() async {
    return _readPrayerTimesList();
  }

  @override
  Future<void> deletePrayerTimes() async {
    await box.delete('prayer_times');
  }

  @override
  Future<PrayerTimesModel?> getPrayerTimesForDate({
    required String date,
  }) async {
    final savedPrayerTimes = _readPrayerTimesList();

    if (savedPrayerTimes == null) {
      return null;
    }

    for (final prayerTime in savedPrayerTimes) {
      if (prayerTime.date.gregorian == date) {
        return prayerTime;
      }
    }

    return null;
  }

  List<PrayerTimesModel>? _readPrayerTimesList() {
    final raw = box.get('prayer_times');

    if (raw == null) {
      return null;
    }

    if (raw is! List) {
      return null;
    }

    return raw.map((item) => item as PrayerTimesModel).toList();
  }
}
