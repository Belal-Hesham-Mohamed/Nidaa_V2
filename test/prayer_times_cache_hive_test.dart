import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:nidaa_v2/prayer_times/data/datasource/prayer_times_local_datasource.dart';
import 'package:nidaa_v2/prayer_times/data/datasource/prayer_times_remote_datasource.dart';
import 'package:nidaa_v2/prayer_times/data/models/prayer_times_model.dart';
import 'package:nidaa_v2/prayer_times/data/repositories/prayer_times_repo.dart';

class _ThrowingRemoteDataSource implements PrayerTimesRemoteDataSource {
  int calendarByCoordinatesCalls = 0;

  Never _shouldNotFetch() {
    throw StateError('Prayer times API should not be called when cache covers required months');
  }

  @override
  Future<List<PrayerTimesModel>> getCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    calendarByCoordinatesCalls++;
    _shouldNotFetch();
  }

  @override
  Future<List<PrayerTimesModel>> getCalendarByAddress({
    required String state,
    required String country,
    required int month,
    required int year,
  }) async =>
      _shouldNotFetch();

  @override
  Future<List<PrayerTimesModel>> getCalendarByCity({
    required String city,
    required String state,
    required String country,
    required int month,
    required int year,
  }) async =>
      _shouldNotFetch();

  @override
  Future<PrayerTimesModel> getTimingsByAddress({
    required String state,
    required String country,
    required String date,
  }) async =>
      _shouldNotFetch();

  @override
  Future<PrayerTimesModel> getTimingsByCity({
    required String city,
    required String state,
    required String country,
    required String date,
  }) async =>
      _shouldNotFetch();

  @override
  Future<PrayerTimesModel> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) async =>
      _shouldNotFetch();
}

PrayerTimesModel _model(String gregorian) {
  return PrayerTimesModel(
    timings: TimingsModel(
      fajr: '04:30',
      sunrise: '06:00',
      dhuhr: '12:00',
      asr: '15:30',
      maghrib: '18:00',
      isha: '19:30',
    ),
    date: DateModel(
      gregorian: gregorian,
      hijri: 'x',
      hijriDate: '09-03-1448',
      hijriMonthEn: 'Rabi al-Awwal',
      hijriMonthAr: 'ربيع الأول',
      hijriYear: '1448',
    ),
    night: NightModel(
      midnight: '00:00',
      firstThird: '22:00',
      lastThird: '02:00',
    ),
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('nidaa_prayer_cache');
    Hive.init(tempDir.path);
    Intl.defaultLocale = 'en';
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PrayerTimesModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TimingsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(DateModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(NightModelAdapter());
    }
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('DateModel.fromJson stores gregorian.date not readable', () {
    final date = DateModel.fromJson({
      'readable': '01 Sep 2026',
      'gregorian': {'date': '01-09-2026'},
      'hijri': {
        'date': '09-03-1448',
        'month': {'en': 'Rabi al-Awwal'},
        'year': '1448',
      },
    });

    expect(date.gregorian, '01-09-2026');
  });

  test('Hive save and restore preserves gregorian dates', () async {
    final boxName = 'prayerTimesBox';
    final saved = [_model('01-09-2026'), _model('31-08-2026')];

    final writeBox = await Hive.openBox(boxName);
    final writeDataSource = PrayerTimesLocalDataSourceImpl(writeBox);
    await writeDataSource.savePrayerTimes(saved);
    await writeBox.close();

    final readBox = await Hive.openBox(boxName);
    final readDataSource = PrayerTimesLocalDataSourceImpl(readBox);
    final restored = await readDataSource.getSavedPrayerTimes();

    expect(restored, isNotNull);
    expect(restored, isA<List<PrayerTimesModel>>());
    expect(restored, hasLength(2));
    expect(restored!.map((item) => item.date.gregorian).toList(), [
      '01-09-2026',
      '31-08-2026',
    ]);
  });

  test('Current Location cache flow reads Hive after restart and detects months from gregorian.date', () async {
    final boxName = 'prayerTimesBox';
    final today = DateTime(2026, 9, 7);
    final saved = [_model('31-08-2026'), _model('01-09-2026'), _model('07-09-2026')];

    final writeBox = await Hive.openBox(boxName);
    await PrayerTimesLocalDataSourceImpl(writeBox).savePrayerTimes(saved);
    await writeBox.close();

    final readBox = await Hive.openBox(boxName);
    final remote = _ThrowingRemoteDataSource();
    final repo = PrayerTimesRepo(
      remote,
      PrayerTimesLocalDataSourceImpl(readBox),
    );

    final result = await repo.getPrayerTimesWithCacheByCoordinates(
      today: today,
      latitude: 30.0444,
      longitude: 31.2357,
    );

    expect(remote.calendarByCoordinatesCalls, 0);
    expect(result.isRight(), isTrue);
    final prayerTimes = result.getOrElse(() => []);
    expect(prayerTimes, hasLength(3));
  });

  test('Cached months parsing accepts stored Aladhan readable dates after Hive reopen', () async {
    final boxName = 'prayerTimesBox';
    final today = DateTime(2026, 9, 7);
    final saved = [_model('01 Aug 2026'), _model('01 Sep 2026'), _model('07-09-2026')];

    final writeBox = await Hive.openBox(boxName);
    await PrayerTimesLocalDataSourceImpl(writeBox).savePrayerTimes(saved);
    await writeBox.close();

    final readBox = await Hive.openBox(boxName);
    final remote = _ThrowingRemoteDataSource();
    final repo = PrayerTimesRepo(
      remote,
      PrayerTimesLocalDataSourceImpl(readBox),
    );

    final result = await repo.getPrayerTimesWithCacheByCoordinates(
      today: today,
      latitude: 30.0444,
      longitude: 31.2357,
    );

    expect(remote.calendarByCoordinatesCalls, 0);
    expect(result.isRight(), isTrue);
    final prayerTimes = result.getOrElse(() => []);
    expect(prayerTimes, hasLength(3));
  });
}
