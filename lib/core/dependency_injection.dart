import 'package:get_it/get_it.dart';
import 'package:nidaa_v2/location/data/datasource/location_datasorce.dart';
import 'package:nidaa_v2/location/data/repositories/location_repo.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<LocationDatasource>(
    () => LocationDatasource(),
  );

  sl.registerLazySingleton<LocationRepo>(
    () => LocationRepo(sl<LocationDatasource>()),
  );
}