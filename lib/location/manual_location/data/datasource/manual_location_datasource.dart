import 'package:country_state_city/country_state_city.dart' as location_data;
import 'package:geocoding/geocoding.dart';
import 'package:nidaa_v2/location/manual_location/data/models/manual_location_model.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location_options.dart';

class ManualLocationDatasource {
  static final Geocoding _geocoding = Geocoding();
  Future<ManualLocationModel> getLocationData({
    required String country,
    required String state,
    String? city,
  }) async {
    final address = [
      city,
      state,
      country,
    ].where((part) => part?.trim().isNotEmpty == true).join(', ');
    final matches = await _geocoding.locationFromAddress(address);
    if (matches.isEmpty) throw StateError('No coordinates found for $address');
    return ManualLocationModel(
      country: country.trim(),
      state: state.trim(),
      city: city?.trim().isNotEmpty == true ? city!.trim() : null,
      latitude: matches.first.latitude,
      longitude: matches.first.longitude,
    );
  }

  Future<List<ManualLocationCountry>> getCountries() async {
    final countries = await location_data.getAllCountries();

    return countries
        .map(
          (country) => ManualLocationCountry(
            name: country.name,
            isoCode: country.isoCode,
          ),
        )
        .toList();
  }

  Future<List<ManualLocationState>> getStates({
    required String countryCode,
  }) async {
    final states = await location_data.getStatesOfCountry(countryCode);

    return states
        .map(
          (state) => ManualLocationState(
            name: state.name,
            countryCode: state.countryCode,
            isoCode: state.isoCode,
          ),
        )
        .toList();
  }

  Future<List<ManualLocationCity>> getCities({
    required String countryCode,
    required String stateCode,
  }) async {
    final cities = await location_data.getStateCities(countryCode, stateCode);

    return cities
        .map(
          (city) => ManualLocationCity(
            name: city.name,
            countryCode: city.countryCode,
            stateCode: city.stateCode,
          ),
        )
        .toList();
  }
}
