abstract class Location {
  final double latitude;
  final double longitude;

  final String? city;
  final String? subLocality;
  final String? administrativeArea;
  final String? country;
  Location({
    required this.latitude,
    required this.longitude,
    this.city,
    this.subLocality,
    this.administrativeArea,
    this.country,
  });
}
