import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nidaa_v2/location/data/exception/exception.dart' hide LocationServiceDisabledException;
import 'package:nidaa_v2/location/data/models/location_model.dart';

import 'package:geolocator/geolocator.dart' as geo;

class LocationDatasource {
  Future<LocationModel> getLocationData() async {
    // 1. Check if location service is enabled
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    // 2. Check current permission
    var permission = await geo.Geolocator.checkPermission();

    // 3. Ask for permission if it has not been granted yet
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    // 4. User denied permission
    if (permission == geo.LocationPermission.denied) {
      throw LocationPermissionDeniedException();
    }

    // 5. User permanently denied permission
    if (permission == geo.LocationPermission.deniedForever) {
      throw LocationPermissionDeniedForeverException();
    }

    try {
      // 6. Get current location
      final position = await geo.Geolocator.getCurrentPosition();

      // 7. Get address information from coordinates
      Placemark? placemark;

      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        placemark = placemarks.first;
      }

      // 8. Return location model
      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        country: placemark?.country,
        city: placemark?.locality,
        administrativeArea: placemark?.administrativeArea,
        subLocality: placemark?.subLocality,
      );
    } catch (_) {
      throw LocationFetchException();
    }
  }
}
