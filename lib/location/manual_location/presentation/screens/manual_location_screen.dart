import 'package:country_state_city/country_state_city.dart' as location_data;
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:flutter/material.dart';
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

  final GlobalKey<CSCPickerPlusState> _pickerKey =
      GlobalKey<CSCPickerPlusState>();

  bool _useCurrentLocation = true;
  bool _isLoadingInitial = true;
  bool _isPickerReady = false;
  bool _isSaving = false;
  bool _isResolvingLocationValue = false;
  String? _validationError;

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

  Future<void> _initData() async {
    try {
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
              _restoreArabicDisplayValues();
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

  Future<void> _restoreArabicDisplayValues() async {
    final picker = _pickerKey.currentState;
    if (picker == null) return;

    try {
      final countries = await picker.getSelectedCountryData();
      if (countries.isEmpty) return;

      final country = countries.first;
      final englishCountry = country.name?.trim();
      final arabicCountry = country.nameAr?.trim();

      String? arabicState;
      if (_stateValue != null) {
        for (final state in country.state ?? <Region>[]) {
          if (state.name?.trim() == _stateValue ||
              state.nameAr?.trim() == _stateValue) {
            arabicState = state.nameAr?.trim();
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _countryDisplayValue =
            arabicCountry?.isNotEmpty == true ? arabicCountry : englishCountry;
        _stateDisplayValue = arabicState ?? _stateValue;
      });
    } catch (_) {
      // Keep the saved English values if the picker has not finished loading.
    }
  }

  Future<void> _resolveEnglishCountryAndState() async {
    final picker = _pickerKey.currentState;
    if (picker == null) return;

    try {
      final countries = await picker.getSelectedCountryData();
      if (countries.isEmpty) return;

      final country = countries.first;
      final englishCountry = country.name?.trim();

      String? englishState;
      if (_stateDisplayValue != null && _stateDisplayValue!.isNotEmpty) {
        for (final state in country.state ?? <Region>[]) {
          if (state.nameAr?.trim() == _stateDisplayValue ||
              state.name?.trim() == _stateDisplayValue) {
            englishState = state.name?.trim();
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _countryValue = englishCountry?.isNotEmpty == true
            ? englishCountry
            : _countryValue;
        _stateValue = englishState?.isNotEmpty == true
            ? englishState
            : (_stateDisplayValue?.isNotEmpty == true
                ? _stateDisplayValue
                : null);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingLocationValue = false;
        });
      }
    }
  }

  Future<void> _resolveEnglishCity() async {
    final picker = _pickerKey.currentState;
    if (picker == null || _cityDisplayValue == null) {
      if (mounted) {
        setState(() {
          _isResolvingLocationValue = false;
        });
      }
      return;
    }

    try {
      final countries = await picker.getSelectedCountryData();
      if (countries.isEmpty) return;

      final country = countries.first;
      final englishCountry = country.name?.trim();
      final selectedState = (country.state ?? <Region>[]).where((state) {
        return state.nameAr?.trim() == _stateDisplayValue ||
            state.name?.trim() == _stateDisplayValue;
      });

      String? englishState;
      String? selectedCity = _cityDisplayValue?.trim();

      if (selectedState.isNotEmpty) {
        final state = selectedState.first;
        englishState = state.name?.trim();
      }

      String? englishCity;

      if (englishCountry != null && englishCountry.isNotEmpty) {
        final countriesData = await location_data.getAllCountries();
        final countryData = countriesData.where((item) {
          return item.name.trim().toLowerCase() ==
              englishCountry.toLowerCase();
        });

        if (countryData.isNotEmpty && englishState != null) {
          final statesData = await location_data.getStatesOfCountry(
            countryData.first.isoCode,
          );
          final stateData = statesData.where((item) {
            return item.name.trim().toLowerCase() ==
                englishState!.toLowerCase();
          });

          if (stateData.isNotEmpty && selectedCity != null) {
            final citiesData = await location_data.getStateCities(
              countryData.first.isoCode,
              stateData.first.isoCode,
            );
            final cityData = citiesData.where((item) {
              return item.name.trim().toLowerCase() ==
                  selectedCity.toLowerCase();
            });

            if (cityData.isNotEmpty) {
              englishCity = cityData.first.name.trim();
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _countryValue = englishCountry?.isNotEmpty == true
            ? englishCountry
            : _countryValue;
        _stateValue = englishState?.isNotEmpty == true
            ? englishState
            : _stateValue;
        _cityValue = englishCity?.isNotEmpty == true
            ? englishCity
            : selectedCity;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingLocationValue = false;
        });
      }
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

    if (_countryValue == null ||
        _countryValue!.trim().isEmpty ||
        _stateValue == null ||
        _stateValue!.trim().isEmpty ||
        _cityValue == null ||
        _cityValue!.trim().isEmpty) {
      setState(() {
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
      city: _cityValue!.trim(),
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
                                      key: _pickerKey,
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
                                        setState(() {
                                          _isResolvingLocationValue = true;
                                          _countryDisplayValue = value;
                                          _stateDisplayValue = null;
                                          _cityDisplayValue = null;
                                          _stateValue = null;
                                          _cityValue = null;
                                        });
                                        _resolveEnglishCountryAndState();
                                      },
                                      onStateChanged: (value) {
                                        setState(() {
                                          _isResolvingLocationValue = true;
                                          _stateDisplayValue = value;
                                          _cityDisplayValue = null;
                                          _cityValue = null;
                                        });
                                        _resolveEnglishCountryAndState();
                                      },
                                      onCityChanged: (value) {
                                        setState(() {
                                          _isResolvingLocationValue = true;
                                          _cityDisplayValue = value;
                                        });
                                        _resolveEnglishCity();
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
                        onPressed: _isSaving || _isResolvingLocationValue
                            ? null
                            : _onSave,
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
                            : Text(S.of(context).save),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
