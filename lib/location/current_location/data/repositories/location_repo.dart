import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/core/network/network_info.dart';
import 'package:nidaa_v2/location/current_location/data/datasource/location_datasorce.dart';
import 'package:nidaa_v2/location/current_location/data/datasource/location_local_datasource.dart';
import 'package:nidaa_v2/location/current_location/data/exception/exception.dart'
    hide LocationServiceDisabledException;
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/repositories/location_repo_base.dart';

class LocationRepo implements LocationRepoBase {
  final LocationDatasource datasource;
  final LocationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  LocationRepo(this.datasource, this.localDataSource, this.networkInfo);

  @override
  Future<Either<Failure, Location>> getLocation() async {
    try {
      // 1. Check internet connection
      final hasInternet = await networkInfo.isConnected;

      // 2. No internet → use saved location
      if (!hasInternet) {
        final savedLocation = await localDataSource.getSavedLocation();

        if (savedLocation != null) {
          return Right(savedLocation);
        }

        return Left(Failure('No internet connection and no saved location'));
      }

      // 3. Internet available → get new GPS/location
      final newLocation = await datasource.getLocationData();

      // 4. Get old location from Hive
      final oldLocation = await localDataSource.getSavedLocation();

      // 5. First time → save new location
      if (oldLocation == null) {
        await localDataSource.saveLocation(newLocation);

        return Right(newLocation);
      }

      // 6. Compare old and new location
      final isSameLocation = _isSameLocation(oldLocation, newLocation);

      // 7. Same location → don't refresh Hive
      if (isSameLocation) {
        return Right(oldLocation);
      }

      // 8. Different location → update Hive
      await localDataSource.saveLocation(newLocation);

      return Right(newLocation);
    } on LocationServiceDisabledException {
      return Left(Failure('Location service is disabled'));
    } on LocationPermissionDeniedException {
      return Left(Failure('Location permission was denied'));
    } on LocationPermissionDeniedForeverException {
      return Left(Failure('Location permission was permanently denied'));
    } on LocationFetchException {
      return Left(Failure('Unable to get current location'));
    } catch (_) {
      return Left(Failure('Something went wrong while getting location'));
    }
  }

  @override
  Future<Either<Failure, Location>> getSavedLocation() async {
    try {
      final savedLocation = await localDataSource.getSavedLocation();

      if (savedLocation != null) {
        return Right(savedLocation);
      }

      return Left(Failure('No saved current location'));
    } catch (_) {
      return Left(
        Failure('Something went wrong while getting saved current location'),
      );
    }
  }

  bool _isSameLocation(Location oldLocation, Location newLocation) {
    // --------------------------------------------------
    // 1. Compare country first
    // --------------------------------------------------

    final oldCountry = _normalize(oldLocation.country);
    final newCountry = _normalize(newLocation.country);

    if (oldCountry.isNotEmpty && newCountry.isNotEmpty) {
      if (oldCountry != newCountry) {
        return false;
      }
    }

    // --------------------------------------------------
    // 2. Compare the other location information
    // --------------------------------------------------

    final oldCity = _normalize(oldLocation.city);
    final newCity = _normalize(newLocation.city);

    final oldAdministrativeArea = _normalize(oldLocation.administrativeArea);
    final newAdministrativeArea = _normalize(newLocation.administrativeArea);

    final oldSubLocality = _normalize(oldLocation.subLocality);
    final newSubLocality = _normalize(newLocation.subLocality);

    final hasTextMatch =
        (oldCity.isNotEmpty && newCity.isNotEmpty && oldCity == newCity) ||
        (oldAdministrativeArea.isNotEmpty &&
            newAdministrativeArea.isNotEmpty &&
            oldAdministrativeArea == newAdministrativeArea) ||
        (oldSubLocality.isNotEmpty &&
            newSubLocality.isNotEmpty &&
            oldSubLocality == newSubLocality);

    if (hasTextMatch) {
      return true;
    }

    // --------------------------------------------------
    // 3. No text match → compare GPS
    // --------------------------------------------------

    final distanceInMeters = Geolocator.distanceBetween(
      oldLocation.latitude,
      oldLocation.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );

    // Change this threshold according to your business rule.
    const gpsThresholdInMeters = 100;

    return distanceInMeters < gpsThresholdInMeters;
  }

  String _normalize(String? value) {
    if (value == null) {
      return '';
    }

    return value.trim().toLowerCase();
  }
}
