import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nidaa_v2/location/current_location/data/exception/exception.dart'
    hide LocationServiceDisabledException;
import 'package:nidaa_v2/location/current_location/data/models/location_model.dart';

import 'package:geolocator/geolocator.dart' as geo;

class LocationDatasource {
  Future<LocationModel> getLocationData({Locale? locale}) async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    var permission = await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    if (permission == geo.LocationPermission.denied) {
      throw LocationPermissionDeniedException();
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw LocationPermissionDeniedForeverException();
    }

    try {
      final position = await geo.Geolocator.getCurrentPosition();

      Placemark? placemark;
      final currentLocale = Intl.getCurrentLocale();
      final languageCode = currentLocale.split('_').first.split('-').first;

      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        locale: Locale(languageCode),
      );

      if (placemarks.isNotEmpty) {
        placemark = placemarks.first;
      }

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
