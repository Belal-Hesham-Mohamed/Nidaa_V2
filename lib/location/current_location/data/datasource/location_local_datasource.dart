import 'package:hive/hive.dart';
import 'package:nidaa_v2/location/current_location/data/models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<void> saveLocation(LocationModel location);
  Future<LocationModel?> getSavedLocation();
  Future<void> deleteLocation();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final Box<LocationModel> box;

  LocationLocalDataSourceImpl(this.box);

  @override
  Future<void> saveLocation(LocationModel location) async {
    await box.put('location', location);
  }

  @override
  Future<LocationModel?> getSavedLocation() async {
    return box.get('location');
  }

  @override
  Future<void> deleteLocation() async {
    await box.delete('location');
  }
}
