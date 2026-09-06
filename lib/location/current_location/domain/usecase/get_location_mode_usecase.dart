import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';
import 'package:nidaa_v2/location/current_location/domain/repositories/location_repo_base.dart';

class GetLocationModeUsecase {
  final LocationRepoBase _locationRepository;

  GetLocationModeUsecase(this._locationRepository);

  Future<Either<Failure, LocationMode>> call() {
    return _locationRepository.getSavedLocationMode();
  }
}
