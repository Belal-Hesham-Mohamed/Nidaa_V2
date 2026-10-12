import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_mode_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_saved_current_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location_options.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_manual_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_saved_manual_location_usecase.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
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
    super.latitude,
    super.longitude,
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
    return locationToReturn == null
        ? Left(Failure('GPS Error'))
        : Right(locationToReturn!);
  }
}

class FakeGetSavedCurrentLocationUsecase
    implements GetSavedCurrentLocationUsecase {
  Location? savedLocation;
  @override
  Future<Either<Failure, Location>> call() async => savedLocation == null
      ? Left(Failure('No saved location'))
      : Right(savedLocation!);
}

class FakeGetSavedManualLocationUsecase
    implements GetSavedManualLocationUsecase {
  ManualLocation? manualLocation;
  @override
  Future<Either<Failure, ManualLocation>> call() async => manualLocation == null
      ? Left(Failure('No manual location'))
      : Right(manualLocation!);
}

class FakeGetManualLocationUsecase implements GetManualLocationUsecase {
  ManualLocation? locationToReturn;
  bool wasCalled = false;

  @override
  Future<Either<Failure, ManualLocation>> call({
    required String country,
    required String state,
    String? city,
  }) async {
    wasCalled = true;
    return locationToReturn == null
        ? Left(Failure('Could not resolve manual location'))
        : Right(locationToReturn!);
  }

  @override
  Future<List<ManualLocationCountry>> getCountries() async => [];

  @override
  Future<List<ManualLocationState>> getStates({required String countryCode}) async => [];

  @override
  Future<List<ManualLocationCity>> getCities({
    required String countryCode,
    required String stateCode,
  }) async => [];
}

class FakeGetPrayerTimesWithCacheUsecase
    implements GetPrayerTimesWithCacheUsecase {
  bool cacheCallMade = false;
  bool replaceCacheCallMade = false;
  final _timings = Timings(
    fajr: '04:30',
    sunrise: '06:00',
    dhuhr: '12:00',
    asr: '15:30',
    maghrib: '18:00',
    isha: '19:30',
  );
  @override
  Future<Either<Failure, List<PrayerTimes>>> call({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) async {
    cacheCallMade = true;
    return Right(_days(today));
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> replaceCache({
    required DateTime today,
    required double latitude,
    required double longitude,
  }) async {
    replaceCacheCallMade = true;
    return Right(_days(today));
  }

  List<PrayerTimes> _days(DateTime today) => List.generate(15, (index) {
    final date = today.add(Duration(days: index - 7));
    return PrayerTimes(
      timings: _timings,
      date: Date(
        gregorian:
            '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}',
        hijriDay: '',
        hijriMonthEn: '',
        hijriMonthAr: '',
        hijriYear: '',
      ),
      night: Night(midnight: '00:00', firstThird: '22:00', lastThird: '02:00'),
    );
  });
}

void main() {
  late PrayerTimesCubit cubit;
  late FakeGetLocationModeUsecase mode;
  late FakeGetLocationUsecase freshLocation;
  late FakeGetSavedCurrentLocationUsecase savedCurrent;
  late FakeGetSavedManualLocationUsecase savedManual;
  late FakeGetManualLocationUsecase resolveManual;
  late FakeGetPrayerTimesWithCacheUsecase calculations;
  setUp(() {
    mode = FakeGetLocationModeUsecase();
    freshLocation = FakeGetLocationUsecase();
    savedCurrent = FakeGetSavedCurrentLocationUsecase();
    savedManual = FakeGetSavedManualLocationUsecase();
    resolveManual = FakeGetManualLocationUsecase();
    calculations = FakeGetPrayerTimesWithCacheUsecase();
    cubit = PrayerTimesCubit(
      mode,
      freshLocation,
      savedCurrent,
      savedManual,
      resolveManual,
      calculations,
    );
  });
  tearDown(() => cubit.close());

  test('manual mode calculates from stored coordinates without GPS', () async {
    mode.mode = LocationMode.manual;
    savedManual.manualLocation = DummyManualLocation(
      country: 'Egypt',
      state: 'Cairo',
      city: 'Cairo',
      latitude: 30.0444,
      longitude: 31.2357,
    );
    await cubit.getPrayerTimes();
    expect(freshLocation.wasCalled, isFalse);
    expect(calculations.cacheCallMade, isTrue);
    expect(cubit.state, isA<PrayerTimesSuccess>());
  });

  test('current mode calculates locally for unchanged coordinates', () async {
    final loc = DummyLocation(
      latitude: 30.04,
      longitude: 31.23,
      city: 'Cairo',
      country: 'Egypt',
    );
    freshLocation.locationToReturn = loc;
    savedCurrent.savedLocation = loc;
    await cubit.getPrayerTimes();
    expect(freshLocation.wasCalled, isTrue);
    expect(calculations.cacheCallMade, isTrue);
    expect(cubit.state, isA<PrayerTimesSuccess>());
  });

  test(
    'current mode refreshes local calculations when coordinates change',
    () async {
      savedCurrent.savedLocation = DummyLocation(
        latitude: 30.04,
        longitude: 31.23,
        city: 'Cairo',
        country: 'Egypt',
      );
      freshLocation.locationToReturn = DummyLocation(
        latitude: 31.20,
        longitude: 29.91,
        city: 'Alexandria',
        country: 'Egypt',
      );
      await cubit.getPrayerTimes();
      expect(freshLocation.wasCalled, isTrue);
      expect(calculations.replaceCacheCallMade, isTrue);
      expect(cubit.state, isA<PrayerTimesSuccess>());
    },
  );

  test('missing manual coordinates reports incomplete location', () async {
    mode.mode = LocationMode.manual;
    savedManual.manualLocation = DummyManualLocation(
      country: 'Egypt',
      state: 'Cairo',
      city: 'Cairo',
    );
    await cubit.getPrayerTimes();
    expect(cubit.state, isA<PrayerTimesFailure>());
  });

  test('legacy manual location is resolved and calculated locally', () async {
    mode.mode = LocationMode.manual;
    savedManual.manualLocation = DummyManualLocation(
      country: 'Egypt',
      state: 'Cairo',
      city: 'Cairo',
    );
    resolveManual.locationToReturn = DummyManualLocation(
      country: 'Egypt',
      state: 'Cairo',
      city: 'Cairo',
      latitude: 30.0444,
      longitude: 31.2357,
    );

    await cubit.getPrayerTimes();

    expect(resolveManual.wasCalled, isTrue);
    expect(calculations.cacheCallMade, isTrue);
    expect(cubit.state, isA<PrayerTimesSuccess>());
  });
}
