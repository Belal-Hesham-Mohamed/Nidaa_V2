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

  String? _validationError;

  int _locationRequestVersion = 0;
  String? _lastLocaleCode;

  List<csc_data.Country> _pickerCountries = const [];

  // ============================================================
  // CANONICAL VALUES
  // These values MUST always be English.
  // These are the values used for saving/API requests.
  // ============================================================

  String? _countryValue;
  String? _stateValue;
  String? _cityValue;

  // ============================================================
  // DISPLAY VALUES
  // These values follow the current application language.
  // ============================================================

  String? _countryDisplayValue;
  String? _stateDisplayValue;
  String? _cityDisplayValue;

  Future<void>? _cityResolutionFuture;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final localeCode = Localizations.localeOf(context).languageCode;

    if (_lastLocaleCode == localeCode) {
      return;
    }

    _lastLocaleCode = localeCode;

    if (!_isLoadingInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshDisplayValues();
        }
      });
    }
  }

  // ============================================================
  // LOAD PICKER DATA
  // ============================================================

  Future<void> _loadPickerData() async {
    final json = await rootBundle.loadString(
      'packages/csc_picker_plus/assets/countries.json',
    );

    final decoded = jsonDecode(json) as List<dynamic>;

    _pickerCountries = decoded
        .map(
          (item) => csc_data.Country.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

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

        _countryValue =
            country?.isNotEmpty == true ? country : null;

        _stateValue =
            state?.isNotEmpty == true ? state : null;

        _cityValue =
            city?.isNotEmpty == true ? city : null;

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
              if (mounted) {
                _refreshDisplayValues();
              }
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

  // ============================================================
  // NORMALIZATION
  // ============================================================

  String _normalizeLocationText(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\u200E\u200F]'), '')
        .trim()
        .toLowerCase();
  }

  String _removeLeadingFlag(String value) {
    return value.replaceFirst(
      RegExp(
        r'^[\u{1F1E6}-\u{1F1FF}]\s*',
        unicode: true,
      ),
      '',
    );
  }

  // ============================================================
  // FIND COUNTRY
  // Supports both English and Arabic.
  // Also supports the flag returned by CSCPickerPlus.
  // ============================================================

  csc_data.Country? _countryFor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final selected = _normalizeLocationText(
      _removeLeadingFlag(value),
    );

    for (final country in _pickerCountries) {
      final english = country.name == null
          ? ''
          : _normalizeLocationText(country.name!);

      final arabic = country.nameAr == null
          ? ''
          : _normalizeLocationText(country.nameAr!);

      if (selected == english ||
          selected == arabic ||
          (english.isNotEmpty && selected.endsWith(english)) ||
          (arabic.isNotEmpty && selected.endsWith(arabic))) {
        return country;
      }
    }

    return null;
  }

  // ============================================================
  // FIND STATE
  // Supports both English and Arabic.
  // ============================================================

  csc_data.Region? _stateFor(
    csc_data.Country? country,
    String? value,
  ) {
    if (country == null ||
        value == null ||
        value.trim().isEmpty) {
      return null;
    }

    final selected = _normalizeLocationText(value);

    for (final state in country.state ?? <csc_data.Region>[]) {
      final english = state.name == null
          ? ''
          : _normalizeLocationText(state.name!);

      final arabic = state.nameAr == null
          ? ''
          : _normalizeLocationText(state.nameAr!);

      if (selected == english || selected == arabic) {
        return state;
      }
    }

    return null;
  }

  // ============================================================
  // REFRESH DISPLAY VALUES AFTER LOCALE CHANGE
  //
  // Canonical values remain English.
  // Only display values are changed.
  // ============================================================

  Future<void> _refreshDisplayValues() async {
    final country = _countryFor(_countryValue);

    final state = _stateFor(
      country,
      _stateValue,
    );

    String? cityDisplay = _cityValue;

    if (country != null &&
        state != null &&
        _cityValue != null &&
        _cityValue!.trim().isNotEmpty) {
      try {
        final countries = await location_data.getAllCountries();

        final sourceCountry = countries.firstWhere(
          (item) =>
              _normalizeLocationText(item.name) ==
              _normalizeLocationText(
                country.name ?? '',
              ),
        );

        final states =
            await location_data.getStatesOfCountry(
          sourceCountry.isoCode,
        );

        final sourceState = states.firstWhere(
          (item) =>
              _normalizeLocationText(item.name) ==
              _normalizeLocationText(
                state.name ?? '',
              ),
        );

        final cities =
            await location_data.getStateCities(
          sourceCountry.isoCode,
          sourceState.isoCode,
        );

        final cityIndex = cities.indexWhere(
          (item) =>
              _normalizeLocationText(item.name) ==
              _normalizeLocationText(_cityValue!),
        );

        final pickerCities =
            state.city ?? <csc_data.City>[];

        if (cityIndex >= 0 &&
            cityIndex < pickerCities.length) {
          final isArabic =
              Localizations.localeOf(context)
                      .languageCode ==
                  'ar';

          cityDisplay = isArabic
              ? pickerCities[cityIndex].name?.trim()
              : cities[cityIndex].name.trim();
        }
      } catch (_) {
        // Keep English canonical value.
        cityDisplay = _cityValue;
      }
    }

    if (!mounted) return;

    final isArabic =
        Localizations.localeOf(context).languageCode ==
            'ar';

    setState(() {
      _countryDisplayValue = isArabic
          ? country?.nameAr?.trim() ?? _countryValue
          : country?.name?.trim() ?? _countryValue;

      _stateDisplayValue = isArabic
          ? state?.nameAr?.trim() ?? _stateValue
          : state?.name?.trim() ?? _stateValue;

      _cityDisplayValue = cityDisplay;
    });
  }

  // ============================================================
  // RESOLVE CITY TO ENGLISH
  // ============================================================

  Future<void> _resolveEnglishCity(
    String displayValue,
  ) async {
    final request = ++_locationRequestVersion;

    final country =
        _countryFor(_countryValue) ??
        _countryFor(_countryDisplayValue);

    final state = _stateFor(
      country,
      _stateValue ?? _stateDisplayValue,
    );

    if (country == null || state == null) {
      if (mounted &&
          request == _locationRequestVersion) {
        setState(() {
          _cityValue = null;
          _isResolvingLocationValue = false;
        });
      }

      return;
    }

    final pickerCities =
        state.city ?? <csc_data.City>[];

    final selectedIndex = pickerCities.indexWhere(
      (city) =>
          _normalizeLocationText(city.name ?? '') ==
          _normalizeLocationText(displayValue),
    );

    if (selectedIndex < 0) {
      if (mounted &&
          request == _locationRequestVersion) {
        setState(() {
          _cityValue = null;
          _isResolvingLocationValue = false;
        });
      }

      return;
    }

    try {
      final countries =
          await location_data.getAllCountries();

      final sourceCountry = countries.firstWhere(
        (item) =>
            _normalizeLocationText(item.name) ==
            _normalizeLocationText(
              country.name ?? '',
            ),
      );

      final states =
          await location_data.getStatesOfCountry(
        sourceCountry.isoCode,
      );

      final sourceState = states.firstWhere(
        (item) =>
            _normalizeLocationText(item.name) ==
            _normalizeLocationText(
              state.name ?? '',
            ),
      );

      final cities =
          await location_data.getStateCities(
        sourceCountry.isoCode,
        sourceState.isoCode,
      );

      if (!mounted ||
          request != _locationRequestVersion) {
        return;
      }

      if (selectedIndex >= cities.length) {
        setState(() {
          _cityValue = null;
          _isResolvingLocationValue = false;
        });

        return;
      }

      // IMPORTANT:
      // country_state_city provides the canonical English city.
      setState(() {
        _cityValue =
            cities[selectedIndex].name.trim();

        _isResolvingLocationValue = false;
      });
    } catch (_) {
      if (mounted &&
          request == _locationRequestVersion) {
        // NEVER save Arabic/native display value
        // as the canonical value.
        setState(() {
          _cityValue = null;
          _isResolvingLocationValue = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE
  //
  // Country + State are required.
  // City is OPTIONAL.
  // ============================================================

  Future<void> _onSave() async {
    setState(() {
      _validationError = null;
    });

    // ----------------------------------------------------------
    // CURRENT LOCATION
    // ----------------------------------------------------------

    if (_useCurrentLocation) {
      setState(() {
        _isSaving = true;
      });

      final result =
          await _saveLocationModeUsecase(
        LocationMode.current,
      );

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

      return;
    }

    // ----------------------------------------------------------
    // MANUAL LOCATION
    //
    // Only Country + State are required.
    // City is optional.
    // ----------------------------------------------------------

    if (_countryValue == null ||
        _countryValue!.trim().isEmpty ||
        _stateValue == null ||
        _stateValue!.trim().isEmpty) {
      setState(() {
        _validationError =
            S.of(context).manualLocationValidationError;
      });

      return;
    }

    setState(() {
      _isSaving = true;
    });

    // If city resolution is still running,
    // wait until it finishes.
    final pendingCityResolution =
        _cityResolutionFuture;

    if (_isResolvingLocationValue &&
        pendingCityResolution != null) {
      await pendingCityResolution;
    }

    if (!mounted) return;

    // ----------------------------------------------------------
    // REQUEST
    //
    // ONLY canonical English values are sent.
    // ----------------------------------------------------------

    final manualSaveResult =
        await _getManualLocationUsecase(
      country: _countryValue!.trim(),
      state: _stateValue!.trim(),
      city: _cityValue?.trim().isNotEmpty == true
          ? _cityValue!.trim()
          : null,
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
            await _saveLocationModeUsecase(
          LocationMode.manual,
        );

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

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

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

    final isArabic =
        Localizations.localeOf(context).languageCode ==
            'ar';

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: primaryText,
        elevation: 0,
        title: Text(
          S.of(context).manualLocationTitle,
        ),
      ),

      body: SafeArea(
        child: _isLoadingInitial
            ? Center(
                child: CircularProgressIndicator(
                  color: accentColor,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          // ==================================================
                          // CURRENT LOCATION SWITCH
                          // ==================================================

                          Material(
                            color: cardColor,
                            borderRadius:
                                BorderRadius.circular(16),
                            clipBehavior:
                                Clip.antiAlias,
                            child: SwitchListTile(
                              value:
                                  _useCurrentLocation,

                              onChanged: (value) {
                                setState(() {
                                  _useCurrentLocation =
                                      value;

                                  _validationError =
                                      null;
                                });

                                if (!value &&
                                    !_isPickerReady) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback(
                                    (_) {
                                      if (!mounted) {
                                        return;
                                      }

                                      setState(() {
                                        _isPickerReady =
                                            true;
                                      });
                                    },
                                  );
                                }
                              },

                              activeThumbColor:
                                  accentColor,

                              secondary: Icon(
                                Icons.my_location,
                                color: accentColor,
                              ),

                              title: Text(
                                S
                                    .of(context)
                                    .manualLocationUseCurrent,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),

                              subtitle: Text(
                                S
                                    .of(context)
                                    .manualLocationUseCurrentSubtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryText,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // MANUAL LOCATION
                          // ==================================================

                          if (!_useCurrentLocation) ...[
                            Text(
                              S
                                  .of(context)
                                  .manualLocationDetailsHeader,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700,
                                color: primaryText,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Container(
                              padding:
                                  const EdgeInsets.all(
                                12,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: cardColor,
                                borderRadius:
                                    BorderRadius.circular(
                                  16,
                                ),
                              ),

                              child: _isPickerReady
                                  ? CSCPickerPlus(
                                      // IMPORTANT:
                                      // Do NOT put selected values
                                      // inside this key.
                                      //
                                      // If the key changes after every
                                      // selection, Flutter destroys and
                                      // recreates the picker and its
                                      // internal selected state.
                                      //
                                      // We only recreate it when locale
                                      // changes.
                                      key: ValueKey(
                                        'manual-location-picker-$isArabic',
                                      ),

                                      layout:
                                          Layout.vertical,

                                      showStates: true,

                                      showCities: true,

                                      flagState:
                                          CountryFlag.ENABLE,

                                      countryStateLanguage:
                                          isArabic
                                              ? CountryStateLanguage
                                                  .arabic
                                              : CountryStateLanguage
                                                  .englishOrNative,

                                      cityLanguage:
                                          CityLanguage.native,

                                      currentCountry:
                                          _countryDisplayValue,

                                      currentState:
                                          _stateDisplayValue,

                                      currentCity:
                                          _cityDisplayValue,

                                      countrySearchPlaceholder:
                                          S
                                              .of(context)
                                              .manualLocationSelectCountry,

                                      stateSearchPlaceholder:
                                          S
                                              .of(context)
                                              .manualLocationSelectState,

                                      citySearchPlaceholder:
                                          S
                                              .of(context)
                                              .manualLocationSelectCity,

                                      countryDropdownLabel:
                                          S
                                              .of(context)
                                              .manualLocationCountry,

                                      stateDropdownLabel:
                                          S
                                              .of(context)
                                              .manualLocationState,

                                      cityDropdownLabel:
                                          S
                                              .of(context)
                                              .manualLocationCity,

                                      selectedItemStyle:
                                          TextStyle(
                                        color:
                                            primaryText,
                                        fontSize: 14,
                                      ),

                                      dropdownHeadingStyle:
                                          TextStyle(
                                        color:
                                            primaryText,
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),

                                      dropdownItemStyle:
                                          TextStyle(
                                        color:
                                            primaryText,
                                        fontSize: 14,
                                      ),

                                      dropdownDecoration:
                                          BoxDecoration(
                                        color:
                                            cardColor,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          12,
                                        ),
                                        border:
                                            Border.all(
                                          color:
                                              secondaryText
                                                  .withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),

                                      disabledDropdownDecoration:
                                          BoxDecoration(
                                        color:
                                            cardColor
                                                .withValues(
                                          alpha: 0.6,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          12,
                                        ),
                                        border:
                                            Border.all(
                                          color:
                                              secondaryText
                                                  .withValues(
                                            alpha: 0.15,
                                          ),
                                        ),
                                      ),

                                      dropdownDialogRadius:
                                          14,

                                      searchBarRadius:
                                          12,

                                      // ==================================================
                                      // COUNTRY
                                      // ==================================================

                                      onCountryChanged:
                                          (value) {
                                        ++_locationRequestVersion;

                                        _cityResolutionFuture =
                                            null;

                                        final country =
                                            _countryFor(
                                          value,
                                        );

                                        setState(() {
                                          _countryDisplayValue =
                                              value;

                                          // ALWAYS ENGLISH
                                          _countryValue =
                                              country
                                                  ?.name
                                                  ?.trim();

                                          // Country changed:
                                          // reset State + City.
                                          _stateDisplayValue =
                                              null;

                                          _cityDisplayValue =
                                              null;

                                          _stateValue =
                                              null;

                                          _cityValue =
                                              null;

                                          _isResolvingLocationValue =
                                              false;

                                          _validationError =
                                              country ==
                                                      null
                                                  ? S
                                                      .of(
                                                          context)
                                                      .manualLocationValidationError
                                                  : null;
                                        });
                                      },

                                      // ==================================================
                                      // STATE
                                      // ==================================================

                                      onStateChanged:
                                          (value) {
                                        ++_locationRequestVersion;

                                        _cityResolutionFuture =
                                            null;

                                        // First use canonical country.
                                        //
                                        // If picker sends localized
                                        // value, use display country
                                        // as fallback.
                                        final country =
                                            _countryFor(
                                              _countryValue,
                                            ) ??
                                            _countryFor(
                                              _countryDisplayValue,
                                            );

                                        final state =
                                            _stateFor(
                                          country,
                                          value,
                                        );

                                        setState(() {
                                          _stateDisplayValue =
                                              value;

                                          // ALWAYS ENGLISH
                                          _stateValue =
                                              state
                                                  ?.name
                                                  ?.trim();

                                          // State changed:
                                          // reset City.
                                          _cityDisplayValue =
                                              null;

                                          _cityValue =
                                              null;

                                          _isResolvingLocationValue =
                                              false;

                                          _validationError =
                                              state ==
                                                      null
                                                  ? S
                                                      .of(
                                                          context)
                                                      .manualLocationValidationError
                                                  : null;
                                        });
                                      },

                                      // ==================================================
                                      // CITY
                                      // ==================================================

                                      onCityChanged:
                                          (value) {
                                        ++_locationRequestVersion;

                                        if (value ==
                                                null ||
                                            value
                                                .trim()
                                                .isEmpty) {
                                          setState(() {
                                            _cityDisplayValue =
                                                null;

                                            _cityValue =
                                                null;

                                            _isResolvingLocationValue =
                                                false;

                                            _cityResolutionFuture =
                                                null;
                                          });

                                          return;
                                        }

                                        setState(() {
                                          _cityDisplayValue =
                                              value;

                                          _isResolvingLocationValue =
                                              true;

                                          _validationError =
                                              null;
                                        });

                                        final future =
                                            _resolveEnglishCity(
                                          value,
                                        );

                                        _cityResolutionFuture =
                                            future;

                                        future.whenComplete(
                                          () {
                                            if (!mounted) {
                                              return;
                                            }

                                            if (identical(
                                              _cityResolutionFuture,
                                              future,
                                            )) {
                                              _cityResolutionFuture =
                                                  null;
                                            }
                                          },
                                        );
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],

                          // ==================================================
                          // VALIDATION ERROR
                          // ==================================================

                          if (_validationError != null) ...[
                            const SizedBox(height: 12),

                            Text(
                              _validationError!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .error,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // SAVE BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        // IMPORTANT:
                        // Do NOT disable Save because of
                        // _isResolvingLocationValue.
                        //
                        // Save will wait for the city resolver
                        // if necessary.
                        onPressed:
                            _isSaving ? null : _onSave,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              accentColor,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),

                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                S
                                    .of(context)
                                    .savedSuffix,
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