import 'package:hive/hive.dart';
import 'package:nidaa_v2/prayer_times/data/models/prayer_times_model.dart';

abstract class PrayerTimesLocalDataSource {
  Future<void> savePrayerTimes(PrayerTimesModel prayerTimes);
  Future<PrayerTimesModel?> getSavedPrayerTimes();
  Future<void> deletePrayerTimes();
}

class PrayerTimesLocalDataSourceImpl implements PrayerTimesLocalDataSource {
  final Box<PrayerTimesModel> box;

  PrayerTimesLocalDataSourceImpl(this.box);

  @override
  Future<void> savePrayerTimes(PrayerTimesModel prayerTimes) async {
    await box.put('prayer_times', prayerTimes);
  }

  @override
  Future<PrayerTimesModel?> getSavedPrayerTimes() async {
    return box.get('prayer_times');
  }

  @override
  Future<void> deletePrayerTimes() async {
    await box.delete('prayer_times');
  }
}
