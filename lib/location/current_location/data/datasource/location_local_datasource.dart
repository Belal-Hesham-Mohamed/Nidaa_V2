import 'package:hive/hive.dart';
import 'package:nidaa_v2/location/current_location/data/models/location_model.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';

abstract class LocationLocalDataSource {
  Future<void> saveLocation(LocationModel location);
  Future<LocationModel?> getSavedLocation();
  Future<void> deleteLocation();
  Future<LocationMode?> getSavedLocationMode();
  Future<void> saveLocationMode(LocationMode mode);
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final Box<LocationModel> box;
  final Box<String> modeBox;

  LocationLocalDataSourceImpl(this.box, this.modeBox);

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

  @override
  Future<LocationMode?> getSavedLocationMode() async {
    final savedMode = modeBox.get('location_mode');

    if (savedMode == null) {
      return null;
    }

    return LocationMode.values.firstWhere(
      (mode) => mode.name == savedMode,
      orElse: () => LocationMode.current,
    );
  }

  @override
  Future<void> saveLocationMode(LocationMode mode) async {
    await modeBox.put('location_mode', mode.name);
  }
}
