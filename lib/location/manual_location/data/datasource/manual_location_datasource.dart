import 'package:country_state_city/country_state_city.dart' as location_data;
import 'package:nidaa_v2/location/manual_location/data/models/manual_location_model.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location_options.dart';

class ManualLocationDatasource {
  Future<ManualLocationModel> getLocationData({
    required String country,
    required String state,
    required String city,
  }) async {
    return ManualLocationModel(
      country: country.trim(),
      state: state.trim(),
      city: city.trim(),
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
