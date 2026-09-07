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
      widget.getSavedManualLocationUsecase ?? sl<GetSavedManualLocationUsecase>();

  GetManualLocationUsecase get _getManualLocationUsecase =>
      widget.getManualLocationUsecase ?? sl<GetManualLocationUsecase>();

  bool _useCurrentLocation = true;
  bool _isLoadingInitial = true;
  bool _isSaving = false;
  String? _validationError;

  String? _countryValue;
  String? _stateValue;
  String? _cityValue;

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
        _isLoadingInitial = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
      });
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
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SwitchListTile(
                              value: _useCurrentLocation,
                              onChanged: (value) {
                                setState(() {
                                  _useCurrentLocation = value;
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
                              child: CSCPickerPlus(
                                layout: Layout.vertical,
                                showStates: true,
                                showCities: true,
                                flagState: CountryFlag.ENABLE,
                                countryStateLanguage: isArabic
                                    ? CountryStateLanguage.arabic
                                    : CountryStateLanguage.englishOrNative,
                                cityLanguage: CityLanguage.native,
                                currentCountry: _countryValue,
                                currentState: _stateValue,
                                currentCity: _cityValue,
                                countrySearchPlaceholder:
                                    S.of(context).manualLocationSelectCountry,
                                stateSearchPlaceholder:
                                    S.of(context).manualLocationSelectState,
                                citySearchPlaceholder:
                                    S.of(context).manualLocationSelectCity,
                                countryDropdownLabel:
                                    S.of(context).manualLocationCountry,
                                stateDropdownLabel:
                                    S.of(context).manualLocationState,
                                cityDropdownLabel:
                                    S.of(context).manualLocationCity,
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
                                    _countryValue = value.trim().isEmpty
                                        ? null
                                        : value.trim();
                                    _stateValue = null;
                                    _cityValue = null;
                                    _validationError = null;
                                  });
                                },
                                onStateChanged: (value) {
                                  setState(() {
                                    _stateValue = value?.trim().isEmpty == true
                                        ? null
                                        : value?.trim();
                                    _cityValue = null;
                                    _validationError = null;
                                  });
                                },
                                onCityChanged: (value) {
                                  setState(() {
                                    _cityValue = value?.trim().isEmpty == true
                                        ? null
                                        : value?.trim();
                                    _validationError = null;
                                  });
                                },
                              ),
                            ),
                          ],
                          if (_validationError != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
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
                                S.of(context).manualLocationSave,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
