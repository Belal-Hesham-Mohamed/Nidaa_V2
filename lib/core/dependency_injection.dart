import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nidaa_v2/core/network/network_info.dart';
import 'package:nidaa_v2/location/data/datasource/location_datasorce.dart';
import 'package:nidaa_v2/location/data/datasource/location_local_datasource.dart';
import 'package:nidaa_v2/location/data/models/location_model.dart';
import 'package:nidaa_v2/location/data/repositories/location_repo.dart';
import 'package:nidaa_v2/location/domain/repositories/location_repo_base.dart';
import 'package:nidaa_v2/location/domain/usecase/get_location_usecase.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Internet connection
  sl.registerLazySingleton<InternetConnection>(
    () => InternetConnection(),
  );

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      sl<InternetConnection>(),
    ),
  );

  // Location datasource
  sl.registerLazySingleton<LocationDatasource>(
    () => LocationDatasource(),
  );

  // Local location datasource
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(
      sl<Box<LocationModel>>(),
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
    () => GetLocationUsecase(
      sl<LocationRepoBase>(),
    ),
  );
}