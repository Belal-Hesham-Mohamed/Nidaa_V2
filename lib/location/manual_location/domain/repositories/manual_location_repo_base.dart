import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location_options.dart';

abstract class ManualLocationRepoBase {
  Future<Either<Failure, ManualLocation>> getLocation({
    required String country,
    required String state,
    required String city,
  });

  Future<Either<Failure, ManualLocation>> getSavedLocation();

  Future<List<ManualLocationCountry>> getCountries();

  Future<List<ManualLocationState>> getStates({required String countryCode});

  Future<List<ManualLocationCity>> getCities({
    required String countryCode,
    required String stateCode,
  });
}
