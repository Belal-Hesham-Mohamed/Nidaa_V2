import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/manual_location/domain/entities/manual_location.dart';
import 'package:nidaa_v2/manual_location/domain/repositories/manual_location_repo_base.dart';

class GetManualLocationUsecase {
  final ManualLocationRepoBase _locationRepository;

  GetManualLocationUsecase(this._locationRepository);

  Future<Either<Failure, ManualLocation>> call({
    required String country,
    required String city,
  }) async {
    return await _locationRepository.getLocation(country: country, city: city);
  }
}
