import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';

abstract class LocationRepoBase {
  Future<Either<Failure, Location>> getLocation();

  Future<Either<Failure, Location>> getSavedLocation();

  Future<Either<Failure, LocationMode>> getSavedLocationMode();

  Future<Either<Failure, LocationMode>> saveLocationMode(LocationMode mode);
}
