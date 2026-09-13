import 'dart:convert';

import 'package:country_state_city/country_state_city.dart' as location_data;
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:csc_picker_plus/model/select_status_model.dart' as csc_data;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/core/dependency_injection.dart';
import 'package:nidaa_v2/generated/l10n.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_mode_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/save_location_mode_usecase.dart';
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
      widget.getSavedManualLocationUsecase ??
      sl<GetSavedManualLocationUsecase>();

  GetManualLocationUsecase get _getManualLocationUsecase =>
      widget.getManualLocationUsecase ?? sl<GetManualLocationUsecase>();

  bool _useCurrentLocation = true;
  bool _isLoadingInitial = true;
  bool _isPickerReady = false;
  bool _isSaving = false;
  bool _isResolvingLocationValue = false;
  Future<void>? _pendingCanonicalCityResolution;
  String? _validationError;
  int _locationRequestVersion = 0;
  String? _lastLocaleCode;
  List<csc_data.Country> _pickerCountries = const [];

  String? _countryValue;
  String? _stateValue;
  String? _cityValue;

  String? _countryDisplayValue;
  String? _stateDisplayValue;
  String? _cityDisplayValue;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_lastLocaleCode == localeCode) return;
    _lastLocaleCode = localeCode;
    if (!_isLoadingInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDisplayValues());
    }
  }

  Future<void> _loadPickerData() async {
    final json = await rootBundle.loadString(
      'packages/csc_picker_plus/assets/countries.json',
    );
    final decoded = jsonDecode(json) as List<dynamic>;
    _pickerCountries = decoded
        .map((item) => csc_data.Country.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> _initData() async {
    try {
      await _loadPickerData();
      final modeResult = await _getLocationModeUsecase();
      final mode = modeResult.fold(
        (_) => LocationMode.current,
        (savedMode) => savedMode,
      );

      String? country;
      String? state;
      String? city;

      if (mode == LocationMode.manual) {
        final savedResult = await _getSavedManualLocationUsecase();
        savedResult.fold(
          (_) {},
          (saved) {
            country = saved.country?.trim();
            state = saved.state?.trim();
            city = saved.city?.trim();
          },
        );
      }

      if (!mounted) return;

      setState(() {
        _useCurrentLocation = mode == LocationMode.current;
        _countryValue = country?.isNotEmpty == true ? country : null;
        _stateValue = state?.isNotEmpty == true ? state : null;
        _cityValue = city?.isNotEmpty == true ? city : null;
        _countryDisplayValue = _countryValue;
        _stateDisplayValue = _stateValue;
        _cityDisplayValue = _cityValue;
        _isLoadingInitial = false;
      });

      if (mode == LocationMode.manual) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _isPickerReady = true;
          });

          if (_countryValue != null ||
              _stateValue != null ||
              _cityValue != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _refreshDisplayValues();
            });
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
      });
    }
  }

  String _normalizeLocationText(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

  csc_data.Country? _countryFor(String? value) {
    final selectedValue = value == null ? '' : _normalizeLocationText(value);
    if (selectedValue.isEmpty) return null;

    for (final country in _pickerCountries) {
      final englishName = country.name == null
          ? ''
          : _normalizeLocationText(country.name!);
      final arabicName = country.nameAr == null
          ? ''
          : _normalizeLocationText(country.nameAr!);

      // With CountryFlag.ENABLE, CSCPickerPlus sends values such as
      // "🇪🇬    مصر". Match the canonical suffix, not the display prefix.
      if (selectedValue == englishName ||
          selectedValue == arabicName ||
          (englishName.isNotEmpty && selectedValue.endsWith(englishName)) ||
          (arabicName.isNotEmpty && selectedValue.endsWith(arabicName))) {
        return country;
      }
    }
    return null;
  }

  csc_data.Region? _stateFor(csc_data.Country? country, String? value) {
    if (country == null || value == null || value.trim().isEmpty) return null;
    final selectedValue = _normalizeLocationText(value);
    for (final state in country.state ?? <csc_data.Region>[]) {
      if ((state.name != null &&
              _normalizeLocationText(state.name!) == selectedValue) ||
          (state.nameAr != null &&
              _normalizeLocationText(state.nameAr!) == selectedValue)) {
        return state;
      }
    }
    return null;
  }

  Future<void> _refreshDisplayValues() async {
    final country = _countryFor(_countryValue);
    final state = _stateFor(country, _stateValue);
    String? cityDisplay = _cityValue;
    if (country != null && state != null && _cityValue != null) {
      try {
        final countries = await location_data.getAllCountries();
        final sourceCountry = countries.firstWhere(
          (item) => item.name.trim().toLowerCase() == country.name!.trim().toLowerCase(),
        );
        final states = await location_data.getStatesOfCountry(sourceCountry.isoCode);
        final sourceState = states.firstWhere(
          (item) => item.name.trim().toLowerCase() == state.name!.trim().toLowerCase(),
        );
        final cities = await location_data.getStateCities(
          sourceCountry.isoCode,
          sourceState.isoCode,
        );
        final cityIndex = cities.indexWhere(
          (item) => item.name.trim().toLowerCase() == _cityValue!.trim().toLowerCase(),
        );
        final pickerCities = state.city ?? <csc_data.City>[];
        if (cityIndex >= 0 && cityIndex < pickerCities.length) {
          cityDisplay = Localizations.localeOf(context).languageCode == 'ar'
              ? pickerCities[cityIndex].name?.trim()
              : cities[cityIndex].name.trim();
        }
      } catch (_) {
        cityDisplay = _cityValue;
      }
    }
    if (!mounted) return;
    setState(() {
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      _countryDisplayValue = isArabic
          ? country?.nameAr?.trim() ?? _countryValue
          : country?.name?.trim() ?? _countryValue;
      _stateDisplayValue = isArabic
          ? state?.nameAr?.trim() ?? _stateValue
          : state?.name?.trim() ?? _stateValue;
      _cityDisplayValue = cityDisplay;
    });
  }

  Future<void> _setCanonicalCity(String? displayValue) async {
    final request = ++_locationRequestVersion;
    if (displayValue == null || displayValue.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _cityDisplayValue = null;
          _cityValue = null;
          _isResolvingLocationValue = false;
          _pendingCanonicalCityResolution = null;
        });
      }
      return;
    }

    final country = _countryFor(_countryValue);
    final state = _stateFor(country, _stateValue);
    final pickerCities = state?.city ?? <csc_data.City>[];
    final cityIndex = pickerCities.indexWhere(
      (city) => city.name?.trim() == displayValue.trim(),
    );

    setState(() {
      _cityDisplayValue = displayValue;
      _isResolvingLocationValue = true;
    });

    try {
      String? canonicalCity;
      if (cityIndex >= 0 && country != null && state != null) {
        final countries = await location_data.getAllCountries();
        final sourceCountry = countries.firstWhere(
          (item) => item.name.trim().toLowerCase() == country.name!.trim().toLowerCase(),
        );
        final states = await location_data.getStatesOfCountry(sourceCountry.isoCode);
        final sourceState = states.firstWhere(
          (item) => item.name.trim().toLowerCase() == state.name!.trim().toLowerCase(),
        );
        final cities = await location_data.getStateCities(
          sourceCountry.isoCode,
          sourceState.isoCode,
        );
        if (cityIndex < cities.length) {
          canonicalCity = cities[cityIndex].name.trim();
        }
      }
      canonicalCity ??= cityIndex >= 0 ? pickerCities[cityIndex].name?.trim() : null;
      if (!mounted || request != _locationRequestVersion) return;
      setState(() => _cityValue = canonicalCity);
    } catch (_) {
      if (mounted && request == _locationRequestVersion) {
        setState(() => _cityValue = cityIndex >= 0 ? pickerCities[cityIndex].name?.trim() : null);
      }
    } finally {
      if (mounted && request == _locationRequestVersion) {
        setState(() {
          _isResolvingLocationValue = false;
          _pendingCanonicalCityResolution = null;
        });
      }
    }
  }

  /// Waits until any in-flight canonical city resolution finishes so the
  /// saved request always uses the canonical English values, never the
  /// localized display values. Returns immediately when nothing is pending.
  Future<void> _awaitCanonicalCityResolution() async {
    while (mounted && _isResolvingLocationValue) {
      final pending = _pendingCanonicalCityResolution;
      if (pending == null) return;
      await pending;
    }
  }

  Future<void> _onSave() async {
    setState(() {
      _validationError = null;
    });

    if (_useCurrentLocation) {
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
        (_) => Navigator.of(context).pop(),
      );
      return;
    }

    // Country + State are required; City is optional. If a canonical city
    // lookup is still running, finish it first so the saved request always
    // uses the canonical English values (never the localized display values).
    if (_isResolvingLocationValue) {
      setState(() {
        _isSaving = true;
      });

      await _awaitCanonicalCityResolution();

      if (!mounted) return;
    }

    if (_countryValue == null ||
        _countryValue!.trim().isEmpty ||
        _stateValue == null ||
        _stateValue!.trim().isEmpty) {
      setState(() {
        _isSaving = false;
        _validationError = S.of(context).manualLocationValidationError;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final manualSaveResult = await _getManualLocationUsecase(
      country: _countryValue!.trim(),
      state: _stateValue!.trim(),
      city: _cityValue?.trim(),
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
        final modeSaveResult =
            await _saveLocationModeUsecase(LocationMode.manual);

        if (!mounted) return;

        modeSaveResult.fold(
          (failure) {
            setState(() {
              _isSaving = false;
              _validationError = failure.message;
            });
          },
          (_) => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final primaryText =
        isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accentColor =
        isDark ? AppColors.darkAccentGold : AppColors.lightAccentBlue;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
            ? Center(child: CircularProgressIndicator(color: accentColor))
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Material(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            clipBehavior: Clip.antiAlias,
                            child: SwitchListTile(
                              value: _useCurrentLocation,
                              onChanged: (value) {
                                setState(() {
                                  _useCurrentLocation = value;
                                  _validationError = null;
                                });

                                if (!value && !_isPickerReady) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (!mounted) return;
                                    setState(() {
                                      _isPickerReady = true;
                                    });
                                  });
                                }
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
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _isPickerReady
                                  ? CSCPickerPlus(
                                      // Recreate only when the UI language changes.
                                      // Recreating on every callback can reset the picker
                                      // and emit null/placeholder values before Save.
                                      key: ValueKey(_lastLocaleCode),
                                      layout: Layout.vertical,
                                      showStates: true,
                                      showCities: true,
                                      flagState: CountryFlag.ENABLE,
                                      countryStateLanguage: isArabic
                                          ? CountryStateLanguage.arabic
                                          : CountryStateLanguage.englishOrNative,
                                      cityLanguage: CityLanguage.native,
                                      currentCountry: _countryDisplayValue,
                                      currentState: _stateDisplayValue,
                                      currentCity: _cityDisplayValue,
                                      countrySearchPlaceholder: S.of(context).manualLocationSelectCountry,
                                      stateSearchPlaceholder: S.of(context).manualLocationSelectState,
                                      citySearchPlaceholder: S.of(context).manualLocationSelectCity,
                                      countryDropdownLabel: S.of(context).manualLocationCountry,
                                      stateDropdownLabel: S.of(context).manualLocationState,
                                      cityDropdownLabel: S.of(context).manualLocationCity,
                                      selectedItemStyle: TextStyle(
                                        color: primaryText,
                                        fontSize: 14,
                                      ),
                                      dropdownHeadingStyle: TextStyle(
                                        color: primaryText,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      dropdownItemStyle: TextStyle(
                                        color: primaryText,
                                        fontSize: 14,
                                      ),
                                      dropdownDecoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: secondaryText.withValues(alpha: 0.25),
                                        ),
                                      ),
                                      disabledDropdownDecoration: BoxDecoration(
                                        color: cardColor.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: secondaryText.withValues(alpha: 0.15),
                                        ),
                                      ),
                                      dropdownDialogRadius: 14,
                                      searchBarRadius: 12,
                                      onCountryChanged: (value) {
                                        final country = _countryFor(value);
                                        setState(() {
                                          _locationRequestVersion++;
                                          _pendingCanonicalCityResolution = null;
                                          _countryDisplayValue = value;
                                          _countryValue = country?.name?.trim();
                                          _stateDisplayValue = null;
                                          _cityDisplayValue = null;
                                          _stateValue = null;
                                          _cityValue = null;
                                          _isResolvingLocationValue = false;
                                          _validationError = null;
                                        });
                                      },
                                      onStateChanged: (value) {
                                        final state = _stateFor(_countryFor(_countryValue), value);
                                        setState(() {
                                          _locationRequestVersion++;
                                          _pendingCanonicalCityResolution = null;
                                          _stateDisplayValue = value;
                                          _stateValue = state?.name?.trim();
                                          _cityDisplayValue = null;
                                          _cityValue = null;
                                          _isResolvingLocationValue = false;
                                          _validationError = null;
                                        });
                                      },
                                      onCityChanged: (value) {
                                        setState(() => _validationError = null);
                                        _pendingCanonicalCityResolution =
                                            _setCanonicalCity(value);
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                          if (_validationError != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _validationError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(S.of(context).savedSuffix),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
