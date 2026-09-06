import 'package:country_state_city/country_state_city.dart';
import 'package:nidaa_v2/location/manual_location/data/models/manual_location_model.dart';

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

  Future<List<Country>> getCountries() {
    return getAllCountries();
  }

  Future<List<State>> getStates({required String countryCode}) {
    return getStatesOfCountry(countryCode);
  }

  Future<List<City>> getCities({
    required String countryCode,
    required String stateCode,
  }) {
    return getStateCities(countryCode, stateCode);
  }
}
