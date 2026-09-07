import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/repositories/location_repo_base.dart';

class GetLocationUsecase {
  final LocationRepoBase _locationRepository;

  GetLocationUsecase(this._locationRepository);

  Future<Either<Failure, Location>> call({Locale? locale}) async {
    return await _locationRepository.getLocation(locale: locale);
  }
}
