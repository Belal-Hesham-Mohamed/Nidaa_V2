// Hive fields are redeclared here because the domain entity is intentionally
// kept independent from persistence annotations.
// ignore_for_file: overridden_fields

import 'package:hive/hive.dart';
import 'package:nidaa_v2/location/domain/entities/location.dart';

part 'location_model.g.dart';

@HiveType(typeId: 0)
class LocationModel extends Location {
  LocationModel({
    required this.latitude,
    required this.longitude,
    this.city,
    this.subLocality,
    this.administrativeArea,
    this.country,
  }) : super(
         latitude: latitude,
         longitude: longitude,
         city: city,
         subLocality: subLocality,
         administrativeArea: administrativeArea,
         country: country,
       );

  @override
  @HiveField(0)
  final double latitude;

  @override
  @HiveField(1)
  final double longitude;

  @override
  @HiveField(2)
  final String? city;

  @override
  @HiveField(3)
  final String? subLocality;

  @override
  @HiveField(4)
  final String? administrativeArea;

  @override
  @HiveField(5)
  final String? country;
}
