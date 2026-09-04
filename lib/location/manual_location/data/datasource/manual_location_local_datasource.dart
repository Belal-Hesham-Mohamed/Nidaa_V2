import 'package:hive/hive.dart';
import 'package:nidaa_v2/location/manual_location/data/models/manual_location_model.dart';

abstract class ManualLocationLocalDataSource {
  Future<void> saveLocation(ManualLocationModel location);
  Future<ManualLocationModel?> getSavedLocation();
  Future<void> deleteLocation();
}

class ManualLocationLocalDataSourceImpl
    implements ManualLocationLocalDataSource {
  final Box<ManualLocationModel> box;

  ManualLocationLocalDataSourceImpl(this.box);

  @override
  Future<void> saveLocation(ManualLocationModel location) async {
    await box.put('manual_location', location);
  }

  @override
  Future<ManualLocationModel?> getSavedLocation() async {
    return box.get('manual_location');
  }

  @override
  Future<void> deleteLocation() async {
    await box.delete('manual_location');
  }
}
