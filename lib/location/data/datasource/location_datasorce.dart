import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nidaa_v2/location/data/models/location_model.dart';

class LocationDatasource {
  Future<LocationModel> getLocationData() async {
    final position = await Geolocator.getCurrentPosition();

    Placemark? placemark;
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        placemark = placemarks.first;
      }
   
    

    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      country: placemark?.country ?? '',
      city: placemark?.locality ?? '',
      administrativeArea: placemark?.administrativeArea ?? '',
      subLocality: placemark?.subLocality ?? '',
    );
  }
}
