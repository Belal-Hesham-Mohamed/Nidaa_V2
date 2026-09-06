import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location_options.dart';
import 'package:nidaa_v2/location/manual_location/domain/repositories/manual_location_repo_base.dart';

class GetManualLocationUsecase {
  final ManualLocationRepoBase _locationRepository;

  GetManualLocationUsecase(this._locationRepository);

  Future<Either<Failure, ManualLocation>> call({
    required String country,
    required String state,
    required String city,
  }) async {
    return await _locationRepository.getLocation(
      country: country,
      state: state,
      city: city,
    );
  }

  Future<List<ManualLocationCountry>> getCountries() {
    return _locationRepository.getCountries();
  }

  Future<List<ManualLocationState>> getStates({required String countryCode}) {
    return _locationRepository.getStates(countryCode: countryCode);
  }

  Future<List<ManualLocationCity>> getCities({
    required String countryCode,
    required String stateCode,
  }) {
    return _locationRepository.getCities(
      countryCode: countryCode,
      stateCode: stateCode,
    );
  }
}
