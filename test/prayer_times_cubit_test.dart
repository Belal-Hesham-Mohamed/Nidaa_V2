import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_mode_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_saved_current_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_saved_manual_location_usecase.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_prayer_times_usecase.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_prayer_times_with_cache_usecase.dart';
import 'package:nidaa_v2/prayer_times/presentation/cubit/prayer_times_cubit.dart';

class DummyLocation extends Location {
  DummyLocation({
    required super.latitude,
    required super.longitude,
    super.city,
    super.country,
  });
}

class DummyManualLocation extends ManualLocation {
  DummyManualLocation({
    super.country,
    super.state,
    super.city,
  });
}

class FakeGetLocationModeUsecase implements GetLocationModeUsecase {
  LocationMode mode = LocationMode.current;
  @override
  Future<Either<Failure, LocationMode>> call() async => Right(mode);
}

class FakeGetLocationUsecase implements GetLocationUsecase {
  Location? locationToReturn;
  bool wasCalled = false;

  @override
  Future<Either<Failure, Location>> call() async {
    wasCalled = true;
    if (locationToReturn != null) {
      return Right(locationToReturn!);
    }
    return Left(Failure('GPS Error'));
  }
}

class FakeGetSavedCurrentLocationUsecase implements GetSavedCurrentLocationUsecase {
  Location? savedLocation;
  @override
  Future<Either<Failure, Location>> call() async {
    if (savedLocation != null) return Right(savedLocation!);
    return Left(Failure('No saved location'));
  }
}

class FakeGetSavedManualLocationUsecase implements GetSavedManualLocationUsecase {
  ManualLocation? manualLocation;
  @override
  Future<Either<Failure, ManualLocation>> call() async {
    if (manualLocation != null) return Right(manualLocation!);
    return Left(Failure('No manual location'));
  }
}

class FakeGetPrayerTimesUsecase implements GetPrayerTimesUsecase {
  bool timingsByCityCalled = false;
  bool timingsByCoordinatesCalled = false;

  PrayerTimes dummyPrayerTimes = PrayerTimes(
    timings: Timings(
      fajr: '04:30',
      sunrise: '06:00',
      dhuhr: '12:00',
      asr: '15:30',
      maghrib: '18:00',
      isha: '19:30',
    ),
    date: Date(gregorian: '07-09-2026', hijri: '25 Safar 1448'),
    night: Night(midnight: '00:00', firstThird: '22:00', lastThird: '02:00'),
  );

  @override
  Future<Either<Failure, PrayerTimes>> getTimingsByCity({
    required String city,
    required String state,
    required String country,
    required String date,
  }) async {
    timingsByCityCalled = true;
    return Right(dummyPrayerTimes);
  }

  @override
  Future<Either<Failure, PrayerTimes>> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    timingsByCoordinatesCalled = true;
    return Right(dummyPrayerTimes);
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCity({
    required String city,
    required String state,
    required String country,
    required int month,
    required int year,
  }) async =>
      Right([dummyPrayerTimes]);

  @override
  Future<Either<Failure, List<PrayerTimes>>> getCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async =>
      Right([dummyPrayerTimes]);
}

class FakeGetPrayerTimesWithCacheUsecase implements GetPrayerTimesWithCacheUsecase {
  bool cacheCallMade = false;
  bool replaceCacheCallMade = false;

  PrayerTimes dummyPrayerTimes = PrayerTimes(
    timings: Timings(
      fajr: '04:30',
      sunrise: '06:00',
      dhuhr: '12:00',
      asr: '15:30',
      maghrib: '18:00',
      isha: '19:30',
    ),
    date: Date(gregorian: '07-09-2026', hijri: '25 Safar 1448'),
    night: Night(midnight: '00:00', firstThird: '22:00', lastThird: '02:00'),
  );

  @override
  Future<Either<Failure, List<PrayerTimes>>> call({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) async {
    cacheCallMade = true;
    return Right([dummyPrayerTimes]);
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> replaceCache({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) async {
    replaceCacheCallMade = true;
    return Right([dummyPrayerTimes]);
  }
}

void main() {
  late PrayerTimesCubit cubit;
  late FakeGetLocationModeUsecase fakeModeUsecase;
  late FakeGetLocationUsecase fakeGetLocationUsecase;
  late FakeGetSavedCurrentLocationUsecase fakeGetSavedCurrentLocationUsecase;
  late FakeGetSavedManualLocationUsecase fakeGetSavedManualLocationUsecase;
  late FakeGetPrayerTimesUsecase fakeGetPrayerTimesUsecase;
  late FakeGetPrayerTimesWithCacheUsecase fakeGetPrayerTimesWithCacheUsecase;

  setUp(() {
    fakeModeUsecase = FakeGetLocationModeUsecase();
    fakeGetLocationUsecase = FakeGetLocationUsecase();
    fakeGetSavedCurrentLocationUsecase = FakeGetSavedCurrentLocationUsecase();
    fakeGetSavedManualLocationUsecase = FakeGetSavedManualLocationUsecase();
    fakeGetPrayerTimesUsecase = FakeGetPrayerTimesUsecase();
    fakeGetPrayerTimesWithCacheUsecase = FakeGetPrayerTimesWithCacheUsecase();

    cubit = PrayerTimesCubit(
      fakeModeUsecase,
      fakeGetLocationUsecase,
      fakeGetSavedCurrentLocationUsecase,
      fakeGetSavedManualLocationUsecase,
      fakeGetPrayerTimesUsecase,
      fakeGetPrayerTimesWithCacheUsecase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('Manual mode should never call GPS', () async {
    fakeModeUsecase.mode = LocationMode.manual;
    fakeGetSavedManualLocationUsecase.manualLocation = DummyManualLocation(
      country: 'Egypt',
      state: 'Cairo',
      city: 'Cairo',
    );

    await cubit.getPrayerTimes();

    expect(fakeGetLocationUsecase.wasCalled, isFalse);
    expect(fakeGetPrayerTimesUsecase.timingsByCityCalled, isTrue);
    expect(cubit.state, isA<PrayerTimesSuccess>());
  });

  test('Current mode with unchanged location uses cache', () async {
    fakeModeUsecase.mode = LocationMode.current;
    final loc = DummyLocation(latitude: 30.04, longitude: 31.23, city: 'Cairo', country: 'Egypt');
    fakeGetLocationUsecase.locationToReturn = loc;
    fakeGetSavedCurrentLocationUsecase.savedLocation = loc;

    await cubit.getPrayerTimes();

    expect(fakeGetLocationUsecase.wasCalled, isTrue);
    expect(fakeGetPrayerTimesWithCacheUsecase.cacheCallMade, isTrue);
    expect(cubit.state, isA<PrayerTimesSuccess>());
  });

  test('Current mode with location change replaces cache', () async {
    fakeModeUsecase.mode = LocationMode.current;
    final oldLoc = DummyLocation(latitude: 30.04, longitude: 31.23, city: 'Cairo', country: 'Egypt');
    final newLoc = DummyLocation(latitude: 31.20, longitude: 29.91, city: 'Alexandria', country: 'Egypt');

    fakeGetSavedCurrentLocationUsecase.savedLocation = oldLoc;
    fakeGetLocationUsecase.locationToReturn = newLoc;

    await cubit.getPrayerTimes();

    expect(fakeGetLocationUsecase.wasCalled, isTrue);
    expect(fakeGetPrayerTimesWithCacheUsecase.replaceCacheCallMade, isTrue);
    expect(cubit.state, isA<PrayerTimesSuccess>());
  });
}
