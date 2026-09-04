// Hive fields are redeclared here because the domain entity is intentionally
// kept independent from persistence annotations.
// ignore_for_file: overridden_fields

import 'package:hive/hive.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location.dart';

part 'manual_location_model.g.dart';

@HiveType(typeId: 1)
class ManualLocationModel extends ManualLocation {
  ManualLocationModel({this.country, this.city})
    : super(country: country, city: city);

  @override
  @HiveField(0)
  final String? country;

  @override
  @HiveField(1)
  final String? city;
}
