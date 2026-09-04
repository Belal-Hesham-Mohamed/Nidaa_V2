import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location.dart';

abstract class ManualLocationRepoBase {
  Future<Either<Failure, ManualLocation>> getLocation({
    required String country,
    required String city,
  });

  Future<Either<Failure, ManualLocation>> getSavedLocation();
}
