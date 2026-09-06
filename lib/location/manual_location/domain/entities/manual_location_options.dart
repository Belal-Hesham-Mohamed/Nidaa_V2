class ManualLocationCountry {
  const ManualLocationCountry({required this.name, required this.isoCode});

  final String name;
  final String isoCode;
}

class ManualLocationState {
  const ManualLocationState({
    required this.name,
    required this.countryCode,
    required this.isoCode,
  });

  final String name;
  final String countryCode;
  final String isoCode;
}

class ManualLocationCity {
  const ManualLocationCity({
    required this.name,
    required this.countryCode,
    required this.stateCode,
  });

  final String name;
  final String countryCode;
  final String stateCode;
}
