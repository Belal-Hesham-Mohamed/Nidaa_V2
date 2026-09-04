import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nidaa_v2/core/network/network_info.dart';
import 'package:nidaa_v2/location/current_location/data/datasource/location_datasorce.dart';
import 'package:nidaa_v2/location/current_location/data/datasource/location_local_datasource.dart';
import 'package:nidaa_v2/location/current_location/data/models/location_model.dart';
import 'package:nidaa_v2/location/current_location/data/repositories/location_repo.dart';
import 'package:nidaa_v2/location/current_location/domain/repositories/location_repo_base.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/data/datasource/manual_location_datasource.dart';
import 'package:nidaa_v2/location/manual_location/data/datasource/manual_location_local_datasource.dart';
import 'package:nidaa_v2/location/manual_location/data/models/manual_location_model.dart';
import 'package:nidaa_v2/location/manual_location/data/repositories/manual_location_repo.dart';
import 'package:nidaa_v2/location/manual_location/domain/repositories/manual_location_repo_base.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_manual_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_saved_manual_location_usecase.dart';
import 'package:nidaa_v2/prayer_times/data/datasource/prayer_times_local_datasource.dart';
import 'package:nidaa_v2/prayer_times/data/models/prayer_times_model.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerSingleton<Box<LocationModel>>(
    Hive.box<LocationModel>('locationBox'),
  );

  sl.registerSingleton<Box<ManualLocationModel>>(
    Hive.box<ManualLocationModel>('manualLocationBox'),
  );

  sl.registerSingleton<Box<PrayerTimesModel>>(
    Hive.box<PrayerTimesModel>('prayerTimesBox'),
  );

  // Internet connection
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnection>()),
  );

  // Location datasource
  sl.registerLazySingleton<LocationDatasource>(() => LocationDatasource());

  // Local location datasource
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(sl<Box<LocationModel>>()),
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

  sl.registerLazySingleton<GetSavedManualLocationUsecase>(
    () => GetSavedManualLocationUsecase(sl<ManualLocationRepoBase>()),
  );

  // Local prayer times datasource
  sl.registerLazySingleton<PrayerTimesLocalDataSource>(
    () => PrayerTimesLocalDataSourceImpl(sl<Box<PrayerTimesModel>>()),
  );
}
