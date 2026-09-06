import 'package:country_state_city/country_state_city.dart' as location_data;
import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/dependency_injection.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_manual_location_usecase.dart';

class ManualLocationScreen extends StatefulWidget {
  const ManualLocationScreen({super.key, this.usecase});

  final GetManualLocationUsecase? usecase;

  @override
  State<ManualLocationScreen> createState() => _ManualLocationScreenState();
}

class _ManualLocationScreenState extends State<ManualLocationScreen> {
  GetManualLocationUsecase get _locationUsecase =>
      widget.usecase ?? sl<GetManualLocationUsecase>();

  List<location_data.Country> _countries = [];
  List<location_data.State> _states = [];
  List<location_data.City> _cities = [];

  location_data.Country? _selectedCountry;
  location_data.State? _selectedState;
  location_data.City? _selectedCity;

  bool _isLoadingCountries = true;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _locationUsecase.getCountries();

      if (!mounted) return;

      setState(() {
        _countries = countries;
        _isLoadingCountries = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingCountries = false;
        _errorMessage = 'Unable to load countries';
      });
    }
  }

  Future<void> _selectCountry() async {
    final country = await _showSelectionSheet<location_data.Country>(
      title: 'Select Country',
      items: _countries,
      labelBuilder: (item) => item.name,
    );

    if (country == null || !mounted) return;

    setState(() {
      _selectedCountry = country;
      _selectedState = null;
      _selectedCity = null;
      _states = [];
      _cities = [];
      _isLoadingStates = true;
      _errorMessage = null;
    });

    try {
      final states = await _locationUsecase.getStates(
        countryCode: country.isoCode,
      );

      if (!mounted) return;

      setState(() {
        _states = states;
        _isLoadingStates = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingStates = false;
        _errorMessage = 'Unable to load states';
      });
    }
  }

  Future<void> _selectState() async {
    if (_selectedCountry == null || _states.isEmpty) return;

    final state = await _showSelectionSheet<location_data.State>(
      title: 'Select State',
      items: _states,
      labelBuilder: (item) => item.name,
    );

    if (state == null || !mounted) return;

    setState(() {
      _selectedState = state;
      _selectedCity = null;
      _cities = [];
      _isLoadingCities = true;
      _errorMessage = null;
    });

    try {
      final cities = await _locationUsecase.getCities(
        countryCode: state.countryCode,
        stateCode: state.isoCode,
      );

      if (!mounted) return;

      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingCities = false;
        _errorMessage = 'Unable to load cities';
      });
    }
  }

  Future<void> _selectCity() async {
    if (_selectedCountry == null || _selectedState == null || _cities.isEmpty) {
      return;
    }

    final city = await _showSelectionSheet<location_data.City>(
      title: 'Select City',
      items: _cities,
      labelBuilder: (item) => item.name,
    );

    if (city == null || !mounted) return;

    setState(() {
      _selectedCity = city;
      _isSaving = true;
    });

    final result = await _locationUsecase(
      country: _selectedCountry!.name,
      state: _selectedState!.name,
      city: city.name,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSaving = false;
          _errorMessage = failure.message;
        });
      },
      (location) {
        Navigator.of(context).pop<ManualLocation>(location);
      },
    );
  }

  Future<T?> _showSelectionSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T item) labelBuilder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SearchSelectionSheet<T>(
        title: title,
        items: items,
        labelBuilder: labelBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Location')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoadingCountries
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    const Text(
                      'Choose your country, state, and city.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    _LocationSelector(
                      label: 'Country',
                      value: _selectedCountry?.name,
                      onTap: _selectCountry,
                    ),
                    const SizedBox(height: 12),
                    _LocationSelector(
                      label: 'State',
                      value: _selectedState?.name,
                      enabled:
                          _selectedCountry != null &&
                          !_isLoadingStates &&
                          _states.isNotEmpty,
                      isLoading: _isLoadingStates,
                      onTap: _selectState,
                    ),
                    const SizedBox(height: 12),
                    _LocationSelector(
                      label: 'City',
                      value: _selectedCity?.name,
                      enabled:
                          _selectedState != null &&
                          !_isLoadingCities &&
                          _cities.isNotEmpty,
                      isLoading: _isLoadingCities,
                      onTap: _selectCity,
                    ),
                    if (_isSaving) ...[
                      const SizedBox(height: 20),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _LocationSelector extends StatelessWidget {
  const _LocationSelector({
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        enabled: enabled,
        title: Text(label),
        subtitle: Text(value ?? 'Select $label'),
        trailing: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.keyboard_arrow_down),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

class _SearchSelectionSheet<T> extends StatefulWidget {
  const _SearchSelectionSheet({
    required this.title,
    required this.items,
    required this.labelBuilder,
  });

  final String title;
  final List<T> items;
  final String Function(T item) labelBuilder;

  @override
  State<_SearchSelectionSheet<T>> createState() =>
      _SearchSelectionSheetState<T>();
}

class _SearchSelectionSheetState<T> extends State<_SearchSelectionSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      return widget
          .labelBuilder(item)
          .toLowerCase()
          .contains(_query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(child: Text('No results'))
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];

                          return ListTile(
                            title: Text(widget.labelBuilder(item)),
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
