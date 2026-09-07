import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nidaa_v2/core/network/network_info.dart';
import 'package:nidaa_v2/core/settings/settings_local_datasource.dart';
import 'package:nidaa_v2/location/current_location/data/datasource/location_datasorce.dart';
import 'package:nidaa_v2/location/current_location/data/datasource/location_local_datasource.dart';
import 'package:nidaa_v2/location/current_location/data/models/location_model.dart';
import 'package:nidaa_v2/location/current_location/data/repositories/location_repo.dart';
import 'package:nidaa_v2/location/current_location/domain/repositories/location_repo_base.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_mode_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_saved_current_location_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/save_location_mode_usecase.dart';
import 'package:nidaa_v2/location/manual_location/data/datasource/manual_location_datasource.dart';
import 'package:nidaa_v2/location/manual_location/data/datasource/manual_location_local_datasource.dart';
import 'package:nidaa_v2/location/manual_location/data/models/manual_location_model.dart';
import 'package:nidaa_v2/location/manual_location/data/repositories/manual_location_repo.dart';
import 'package:nidaa_v2/location/manual_location/domain/repositories/manual_location_repo_base.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_manual_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_saved_manual_location_usecase.dart';
import 'package:nidaa_v2/prayer_times/data/datasource/prayer_times_local_datasource.dart';
import 'package:nidaa_v2/prayer_times/data/datasource/prayer_times_remote_datasource.dart';
import 'package:nidaa_v2/prayer_times/data/repositories/prayer_times_repo.dart';
import 'package:nidaa_v2/prayer_times/domain/repositories/prayer_times_repo_base.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_prayer_times_usecase.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_prayer_times_with_cache_usecase.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_saved_prayer_times_usecase.dart';
import 'package:nidaa_v2/prayer_times/presentation/cubit/prayer_times_cubit.dart';

final sl = GetIt.instance;

void setupServiceLocator(SettingsLocalDataSource settingsLocalDataSource) {
  sl.registerSingleton<SettingsLocalDataSource>(settingsLocalDataSource);

  sl.registerSingleton<Box<LocationModel>>(
    Hive.box<LocationModel>('locationBox'),
  );

  sl.registerSingleton<Box<String>>(
    Hive.box<String>('locationModeBox'),
  );

  sl.registerSingleton<Box<ManualLocationModel>>(
    Hive.box<ManualLocationModel>('manualLocationBox'),
  );

  sl.registerSingleton<Box>(
    Hive.box('prayerTimesBox'),
  );

  // Internet connection
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnection>()),
  );

  // Location datasource
  sl.registerLazySingleton<LocationDatasource>(
    () => LocationDatasource(sl<SettingsLocalDataSource>()),
  );

  // Local location datasource
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(
      sl<Box<LocationModel>>(),
      sl<Box<String>>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<LocationRepoBase>(
    () => LocationRepo(
      sl<LocationDatasource>(),
      sl<LocationLocalDataSource>(),
      sl<NetworkInfo>(),
    ),
  );

  // Use case
  sl.registerLazySingleton<GetLocationUsecase>(
    () => GetLocationUsecase(sl<LocationRepoBase>()),
  );

  sl.registerLazySingleton<GetSavedCurrentLocationUsecase>(
    () => GetSavedCurrentLocationUsecase(sl<LocationRepoBase>()),
  );

  sl.registerLazySingleton<GetLocationModeUsecase>(
    () => GetLocationModeUsecase(sl<LocationRepoBase>()),
  );

  sl.registerLazySingleton<SaveLocationModeUsecase>(
    () => SaveLocationModeUsecase(sl<LocationRepoBase>()),
  );

  // Manual location datasource
  sl.registerLazySingleton<ManualLocationDatasource>(
    () => ManualLocationDatasource(),
  );

  // Local manual location datasource
  sl.registerLazySingleton<ManualLocationLocalDataSource>(
    () => ManualLocationLocalDataSourceImpl(sl<Box<ManualLocationModel>>()),
  );

  // Manual location repository
  sl.registerLazySingleton<ManualLocationRepoBase>(
    () => ManualLocationRepo(
      sl<ManualLocationDatasource>(),
      sl<ManualLocationLocalDataSource>(),
    ),
  );

  // Manual location use cases
  sl.registerLazySingleton<GetManualLocationUsecase>(
    () => GetManualLocationUsecase(sl<ManualLocationRepoBase>()),
  );
  sl.registerLazySingleton<GetPrayerTimesWithCacheUsecase>(
    () => GetPrayerTimesWithCacheUsecase(sl()),
  );
  sl.registerLazySingleton<GetSavedManualLocationUsecase>(
    () => GetSavedManualLocationUsecase(sl<ManualLocationRepoBase>()),
  );

  // Local prayer times datasource
  sl.registerLazySingleton<PrayerTimesLocalDataSource>(
    () => PrayerTimesLocalDataSourceImpl(sl<Box>()),
  );

  // Prayer times datasource
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<PrayerTimesRemoteDataSource>(
    () => PrayerTimesRemoteDataSourceImpl(sl<Dio>()),
  );

  // Prayer times repository
  sl.registerLazySingleton<PrayerTimesRepoBase>(
    () => PrayerTimesRepo(
      sl<PrayerTimesRemoteDataSource>(),
      sl<PrayerTimesLocalDataSource>(),
    ),
  );

  // Prayer times use case
  sl.registerLazySingleton<GetPrayerTimesUsecase>(
    () => GetPrayerTimesUsecase(sl<PrayerTimesRepoBase>()),
  );

  sl.registerLazySingleton<GetSavedPrayerTimesUsecase>(
    () => GetSavedPrayerTimesUsecase(sl<PrayerTimesRepoBase>()),
  );

  // Prayer times Cubit
  sl.registerFactory<PrayerTimesCubit>(
    () => PrayerTimesCubit(
      sl<GetLocationModeUsecase>(),
      sl<GetLocationUsecase>(),
      sl<GetSavedCurrentLocationUsecase>(),
      sl<GetSavedManualLocationUsecase>(),
      sl<GetPrayerTimesUsecase>(),
      sl<GetPrayerTimesWithCacheUsecase>(),
    ),
  );
}
