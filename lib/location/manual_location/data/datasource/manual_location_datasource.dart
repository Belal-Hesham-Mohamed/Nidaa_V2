import 'package:nidaa_v2/location/manual_location/data/models/manual_location_model.dart';

class ManualLocationDatasource {
  Future<ManualLocationModel> getLocationData({
    required String country,
    required String city,
  }) async {
    return ManualLocationModel(country: country.trim(), city: city.trim());
  }
}
