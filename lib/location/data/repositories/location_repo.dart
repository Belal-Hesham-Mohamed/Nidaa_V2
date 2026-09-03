import 'package:dartz/dartz.dart';
import 'package:nidaa_v2/core/error/failuer.dart';
import 'package:nidaa_v2/location/data/datasource/location_datasorce.dart';
import 'package:nidaa_v2/location/domain/entities/location.dart';
import 'package:nidaa_v2/location/domain/repositories/location_repo_base.dart';

class LocationRepo implements LocationRepoBase {
  final LocationDatasource datasource;

  LocationRepo(this.datasource);

  @override
  Future<Either<Failuer, Location>> getLocation() async {
    
      final result = await datasource.getLocationData();

      return Right(result);
  
  }
}