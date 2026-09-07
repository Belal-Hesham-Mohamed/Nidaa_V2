import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/core/network/network_info.dart';
import 'package:nidaa_v2/location/current_location/data/datasource/location_datasorce.dart';
import 'package:nidaa_v2/location/current_location/data/datasource/location_local_datasource.dart';
import 'package:nidaa_v2/location/current_location/data/exception/exception.dart'
    hide LocationServiceDisabledException;
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';
import 'package:nidaa_v2/location/current_location/domain/repositories/location_repo_base.dart';

class LocationRepo implements LocationRepoBase {
  final LocationDatasource datasource;
  final LocationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  LocationRepo(this.datasource, this.localDataSource, this.networkInfo);

  @override
  Future<Either<Failure, Location>> getLocation({Locale? locale}) async {
    try {
      final hasInternet = await networkInfo.isConnected;

      if (!hasInternet) {
        final savedLocation = await localDataSource.getSavedLocation();

        if (savedLocation != null) {
          return Right(savedLocation);
        }

        return Left(Failure('No internet connection and no saved location'));
      }

      final newLocation = await datasource.getLocationData(locale: locale);
      final oldLocation = await localDataSource.getSavedLocation();

      if (oldLocation == null) {
        await localDataSource.saveLocation(newLocation);
        return Right(newLocation);
      }

      final isSameLocation = _isSameLocation(oldLocation, newLocation);

      if (isSameLocation) {
        return Right(newLocation);
      }

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

  @override
  Future<Either<Failure, LocationMode>> getSavedLocationMode() async {
    try {
      final savedMode = await localDataSource.getSavedLocationMode();
      return Right(savedMode ?? LocationMode.current);
    } catch (_) {
      return Left(Failure('Something went wrong while getting location mode'));
    }
  }

  @override
  Future<Either<Failure, LocationMode>> saveLocationMode(
    LocationMode mode,
  ) async {
    try {
      await localDataSource.saveLocationMode(mode);
      return Right(mode);
    } catch (_) {
      return Left(Failure('Something went wrong while saving location mode'));
    }
  }

  bool _isSameLocation(Location oldLocation, Location newLocation) {
    final distanceInMeters = Geolocator.distanceBetween(
      oldLocation.latitude,
      oldLocation.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );

    const gpsThresholdInMeters = 100;
    return distanceInMeters < gpsThresholdInMeters;
  }
}
