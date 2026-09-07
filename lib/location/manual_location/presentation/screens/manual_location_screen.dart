import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/core/dependency_injection.dart';
import 'package:nidaa_v2/generated/l10n.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_mode_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/save_location_mode_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/entities/manual_location_options.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_manual_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_saved_manual_location_usecase.dart';

class ManualLocationScreen extends StatefulWidget {
  const ManualLocationScreen({
    super.key,
    this.getLocationModeUsecase,
    this.saveLocationModeUsecase,
    this.getSavedManualLocationUsecase,
    this.getManualLocationUsecase,
  });

  final GetLocationModeUsecase? getLocationModeUsecase;
  final SaveLocationModeUsecase? saveLocationModeUsecase;
  final GetSavedManualLocationUsecase? getSavedManualLocationUsecase;
  final GetManualLocationUsecase? getManualLocationUsecase;

  @override
  State<ManualLocationScreen> createState() => _ManualLocationScreenState();
}

class _ManualLocationScreenState extends State<ManualLocationScreen> {
  GetLocationModeUsecase get _getLocationModeUsecase =>
      widget.getLocationModeUsecase ?? sl<GetLocationModeUsecase>();

  SaveLocationModeUsecase get _saveLocationModeUsecase =>
      widget.saveLocationModeUsecase ?? sl<SaveLocationModeUsecase>();

  GetSavedManualLocationUsecase get _getSavedManualLocationUsecase =>
      widget.getSavedManualLocationUsecase ?? sl<GetSavedManualLocationUsecase>();

  GetManualLocationUsecase get _getManualLocationUsecase =>
      widget.getManualLocationUsecase ?? sl<GetManualLocationUsecase>();

  bool _useCurrentLocation = true;

  List<ManualLocationCountry> _countries = [];
  List<ManualLocationState> _states = [];
  List<ManualLocationCity> _cities = [];

  ManualLocationCountry? _selectedCountry;
  ManualLocationState? _selectedState;
  ManualLocationCity? _selectedCity;

  bool _isLoadingInitial = true;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;
  bool _isSaving = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      // 1. Load saved LocationMode
      final modeResult = await _getLocationModeUsecase();
      final mode = modeResult.fold(
        (_) => LocationMode.current,
        (savedMode) => savedMode,
      );

      final bool useCurrent = (mode == LocationMode.current);

      // 2. Load countries
      final countries = await _getManualLocationUsecase.getCountries();

      // 3. If mode is manual, load saved manual location
      ManualLocationCountry? initialCountry;
      ManualLocationState? initialState;
      ManualLocationCity? initialCity;
      List<ManualLocationState> states = [];
      List<ManualLocationCity> cities = [];

      if (!useCurrent) {
        final savedManualResult = await _getSavedManualLocationUsecase();
        await savedManualResult.fold(
          (_) async {},
          (savedManual) async {
            if (savedManual.country != null && savedManual.country!.isNotEmpty) {
              final countryMatches = countries.where(
                (c) => c.name.trim().toLowerCase() == savedManual.country!.trim().toLowerCase(),
              );
              if (countryMatches.isNotEmpty) {
                initialCountry = countryMatches.first;
              }
            }

            if (initialCountry != null) {
              try {
                states = await _getManualLocationUsecase.getStates(
                  countryCode: initialCountry!.isoCode,
                );

                if (savedManual.state != null && savedManual.state!.isNotEmpty) {
                  final stateMatches = states.where(
                    (s) => s.name.trim().toLowerCase() == savedManual.state!.trim().toLowerCase(),
                  );
                  if (stateMatches.isNotEmpty) {
                    initialState = stateMatches.first;
                  }
                }

                if (initialState != null) {
                  cities = await _getManualLocationUsecase.getCities(
                    countryCode: initialState!.countryCode,
                    stateCode: initialState!.isoCode,
                  );

                  if (savedManual.city != null && savedManual.city!.isNotEmpty) {
                    final cityMatches = cities.where(
                      (c) => c.name.trim().toLowerCase() == savedManual.city!.trim().toLowerCase(),
                    );
                    if (cityMatches.isNotEmpty) {
                      initialCity = cityMatches.first;
                    }
                  }
                }
              } catch (_) {}
            }
          },
        );
      }

      if (!mounted) return;

      setState(() {
        _useCurrentLocation = useCurrent;
        _countries = countries;
        _states = states;
        _cities = cities;
        _selectedCountry = initialCountry;
        _selectedState = initialState;
        _selectedCity = initialCity;
        _isLoadingInitial = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _selectCountry() async {
    final s = S.of(context);
    final country = await _showSelectionSheet<ManualLocationCountry>(
      title: s.manualLocationSelectCountry,
      items: _countries,
      labelBuilder: (item) => item.name,
    );

    if (country == null || !mounted) return;
    if (country == _selectedCountry) return;

    setState(() {
      _selectedCountry = country;
      _selectedState = null;
      _selectedCity = null;
      _states = [];
      _cities = [];
      _isLoadingStates = true;
      _validationError = null;
    });

    try {
      final states = await _getManualLocationUsecase.getStates(
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
        _validationError = s.manualLocationFailedStates;
      });
    }
  }

  Future<void> _selectState() async {
    if (_selectedCountry == null || _states.isEmpty) return;

    final s = S.of(context);
    final state = await _showSelectionSheet<ManualLocationState>(
      title: s.manualLocationSelectState,
      items: _states,
      labelBuilder: (item) => item.name,
    );

    if (state == null || !mounted) return;
    if (state == _selectedState) return;

    setState(() {
      _selectedState = state;
      _selectedCity = null;
      _cities = [];
      _isLoadingCities = true;
      _validationError = null;
    });

    try {
      final cities = await _getManualLocationUsecase.getCities(
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
        _validationError = s.manualLocationFailedCities;
      });
    }
  }

  Future<void> _selectCity() async {
    if (_selectedCountry == null || _selectedState == null || _cities.isEmpty) return;

    final s = S.of(context);
    final city = await _showSelectionSheet<ManualLocationCity>(
      title: s.manualLocationSelectCity,
      items: _cities,
      labelBuilder: (item) => item.name,
    );

    if (city == null || !mounted) return;

    setState(() {
      _selectedCity = city;
      _validationError = null;
    });
  }

  Future<void> _onSave() async {
    setState(() {
      _validationError = null;
    });

    if (_useCurrentLocation) {
      // CASE A: Current Location = ON -> Save LocationMode.current
      setState(() {
        _isSaving = true;
      });

      final result = await _saveLocationModeUsecase(LocationMode.current);

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isSaving = false;
            _validationError = failure.message;
          });
        },
        (_) {
          Navigator.of(context).pop();
        },
      );
    } else {
      // CASE B: Current Location = OFF -> Validation required (Country, State, City)
      if (_selectedCountry == null || _selectedState == null || _selectedCity == null) {
        setState(() {
          _validationError = S.of(context).manualLocationValidationError;
        });
        return;
      }

      setState(() {
        _isSaving = true;
      });

      // Save Manual Location data
      final manualSaveResult = await _getManualLocationUsecase(
        country: _selectedCountry!.name,
        state: _selectedState!.name,
        city: _selectedCity!.name,
      );

      if (!mounted) return;

      await manualSaveResult.fold(
        (failure) async {
          setState(() {
            _isSaving = false;
            _validationError = failure.message;
          });
        },
        (_) async {
          // Save LocationMode.manual
          final modeSaveResult = await _saveLocationModeUsecase(LocationMode.manual);

          if (!mounted) return;

          modeSaveResult.fold(
            (failure) {
              setState(() {
                _isSaving = false;
                _validationError = failure.message;
              });
            },
            (_) {
              Navigator.of(context).pop();
            },
          );
        },
      );
    }
  }

  Future<T?> _showSelectionSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T item) labelBuilder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSelectionSheet<T>(
        title: title,
        items: items,
        labelBuilder: labelBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;
    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final accentColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentBlue;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: primaryText,
        elevation: 0,
        title: Text(S.of(context).manualLocationTitle),
      ),
      body: SafeArea(
        child: _isLoadingInitial
            ? Center(
                child: CircularProgressIndicator(color: accentColor),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          // Toggle Card
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SwitchListTile(
                              value: _useCurrentLocation,
                              onChanged: (val) {
                                setState(() {
                                  _useCurrentLocation = val;
                                  _validationError = null;
                                });
                              },
                              activeThumbColor: accentColor,
                              secondary: Icon(
                                Icons.my_location,
                                color: accentColor,
                              ),
                              title: Text(
                                S.of(context).manualLocationUseCurrent,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                              subtitle: Text(
                                S.of(context).manualLocationUseCurrentSubtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryText,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Manual Location Selectors (Visible only when Current Location is OFF)
                          if (!_useCurrentLocation) ...[
                            Text(
                              S.of(context).manualLocationDetailsHeader,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: primaryText,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Country Selector
                            _LocationSelectorCard(
                              label: S.of(context).manualLocationCountry,
                              value: _selectedCountry?.name,
                              cardColor: cardColor,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              accentColor: accentColor,
                              onTap: _selectCountry,
                            ),
                            const SizedBox(height: 12),

                            // State Selector
                            _LocationSelectorCard(
                              label: S.of(context).manualLocationState,
                              value: _selectedState?.name,
                              cardColor: cardColor,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              accentColor: accentColor,
                              enabled: _selectedCountry != null && !_isLoadingStates && _states.isNotEmpty,
                              isLoading: _isLoadingStates,
                              onTap: _selectState,
                            ),
                            const SizedBox(height: 12),

                            // City Selector
                            _LocationSelectorCard(
                              label: S.of(context).manualLocationCity,
                              value: _selectedCity?.name,
                              cardColor: cardColor,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              accentColor: accentColor,
                              enabled: _selectedState != null && !_isLoadingCities && _cities.isNotEmpty,
                              isLoading: _isLoadingCities,
                              onTap: _selectCity,
                            ),
                          ],

                          if (_validationError != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _validationError!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Save Button
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                S.of(context).manualLocationSaveButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _LocationSelectorCard extends StatelessWidget {
  const _LocationSelectorCard({
    required this.label,
    required this.value,
    required this.onTap,
    required this.cardColor,
    required this.primaryText,
    required this.secondaryText,
    required this.accentColor,
    this.enabled = true,
    this.isLoading = false,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final Color cardColor;
  final Color primaryText;
  final Color secondaryText;
  final Color accentColor;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? cardColor : cardColor.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value ?? S.of(context).manualLocationSelect(label),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
                        color: value != null ? primaryText : secondaryText.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentColor,
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled ? accentColor : secondaryText.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
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
  State<_SearchSelectionSheet<T>> createState() => _SearchSelectionSheetState<T>();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final accentColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentBlue;

    final filteredItems = widget.items.where((item) {
      return widget.labelBuilder(item).toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.75,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: secondaryText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(color: primaryText),
            decoration: InputDecoration(
              hintText: S.of(context).manualLocationSearchHint,
              hintStyle: TextStyle(color: secondaryText),
              prefixIcon: Icon(Icons.search, color: accentColor),
              filled: true,
              fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      S.of(context).manualLocationNoResults,
                      style: TextStyle(color: secondaryText),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: secondaryText.withValues(alpha: 0.1),
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final label = widget.labelBuilder(item);

                      return ListTile(
                        title: Text(
                          label,
                          style: TextStyle(color: primaryText),
                        ),
                        onTap: () => Navigator.of(context).pop(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
