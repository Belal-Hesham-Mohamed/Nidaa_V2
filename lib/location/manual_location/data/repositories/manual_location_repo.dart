import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/manual_location/data/datasource/manual_location_datasource.dart';
import 'package:nidaa_v2/location/manual_location/data/datasource/manual_location_local_datasource.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location_options.dart';
import 'package:nidaa_v2/location/manual_location/domain/repositories/manual_location_repo_base.dart';

class ManualLocationRepo implements ManualLocationRepoBase {
  final ManualLocationDatasource datasource;
  final ManualLocationLocalDataSource localDataSource;

  ManualLocationRepo(this.datasource, this.localDataSource);

  @override
  Future<Either<Failure, ManualLocation>> getLocation({
    required String country,
    required String state,
    required String city,
  }) async {
    try {
      final newLocation = await datasource.getLocationData(
        country: country,
        state: state,
        city: city,
      );

      final oldLocation = await localDataSource.getSavedLocation();

      if (oldLocation == null) {
        await localDataSource.saveLocation(newLocation);
        return Right(newLocation);
      }

      final isSameLocation = _isSameLocation(oldLocation, newLocation);

      if (isSameLocation) {
        return Right(oldLocation);
      }

      await localDataSource.saveLocation(newLocation);
      return Right(newLocation);
    } catch (_) {
      return Left(
        Failure('Something went wrong while setting manual location'),
      );
    }
  }

  @override
  Future<Either<Failure, ManualLocation>> getSavedLocation() async {
    try {
      final savedLocation = await localDataSource.getSavedLocation();

      if (savedLocation != null) {
        return Right(savedLocation);
      }

      return Left(Failure('No saved manual location'));
    } catch (_) {
      return Left(
        Failure('Something went wrong while getting saved manual location'),
      );
    }
  }

  bool _isSameLocation(ManualLocation oldLocation, ManualLocation newLocation) {
    final oldCountry = _normalize(oldLocation.country);
    final newCountry = _normalize(newLocation.country);

    final oldCity = _normalize(oldLocation.city);
    final newCity = _normalize(newLocation.city);

    final oldState = _normalize(oldLocation.state);
    final newState = _normalize(newLocation.state);

    return oldCountry == newCountry &&
        oldState == newState &&
        oldCity == newCity;
  }

  @override
  Future<List<ManualLocationCountry>> getCountries() {
    return datasource.getCountries();
  }

  @override
  Future<List<ManualLocationState>> getStates({required String countryCode}) {
    return datasource.getStates(countryCode: countryCode);
  }

  @override
  Future<List<ManualLocationCity>> getCities({
    required String countryCode,
    required String stateCode,
  }) {
    return datasource.getCities(countryCode: countryCode, stateCode: stateCode);
  }

  String _normalize(String? value) {
    if (value == null) {
      return '';
    }

    return value.trim().toLowerCase();
  }
}
