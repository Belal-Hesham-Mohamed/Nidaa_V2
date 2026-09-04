class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => message;
}
class LocationServiceDisabledException implements Exception {}

class LocationPermissionDeniedException implements Exception {}

class LocationPermissionDeniedForeverException implements Exception {}

class LocationFetchException implements Exception {}