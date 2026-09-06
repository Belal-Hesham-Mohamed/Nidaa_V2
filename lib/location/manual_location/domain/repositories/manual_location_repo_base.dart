import 'package:dartz/dartz.dart';
import 'package:country_state_city/country_state_city.dart' as location_data;
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location.dart';

abstract class ManualLocationRepoBase {
  Future<Either<Failure, ManualLocation>> getLocation({
    required String country,
    required String state,
    required String city,
  });

  Future<Either<Failure, ManualLocation>> getSavedLocation();

  Future<List<location_data.Country>> getCountries();

  Future<List<location_data.State>> getStates({required String countryCode});

  Future<List<location_data.City>> getCities({
    required String countryCode,
    required String stateCode,
  });
}
