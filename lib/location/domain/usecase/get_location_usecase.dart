import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/data/repositories/location_repo.dart';
import 'package:nidaa_v2/location/domain/entities/location.dart';

class GetLocationUsecase {
  final LocationRepo _locationRepository;

  GetLocationUsecase(this._locationRepository);

  Future<Either<Failuer, Location>> call() async {
    return await _locationRepository.getLocation();
  }

}