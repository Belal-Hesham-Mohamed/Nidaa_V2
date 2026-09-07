// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Nidaa`
  String get appTitle => Intl.message(
        'Nidaa',
        name: 'appTitle',
        desc: '',
        args: [],
      );

  /// `Prayer Times`
  String get navPrayerTimes => Intl.message(
        'Prayer Times',
        name: 'navPrayerTimes',
        desc: '',
        args: [],
      );

  /// `Qibla`
  String get navQibla => Intl.message(
        'Qibla',
        name: 'navQibla',
        desc: '',
        args: [],
      );

  /// `Azkar`
  String get navAzkar => Intl.message(
        'Azkar',
        name: 'navAzkar',
        desc: '',
        args: [],
      );

  /// `Settings`
  String get navSettings => Intl.message(
        'Settings',
        name: 'navSettings',
        desc: '',
        args: [],
      );

  /// `Coming Soon`
  String get comingSoon => Intl.message(
        'Coming Soon',
        name: 'comingSoon',
        desc: '',
        args: [],
      );

  /// `Retry`
  String get retry => Intl.message(
        'Retry',
        name: 'retry',
        desc: '',
        args: [],
      );

  /// `remaining`
  String get remaining => Intl.message(
        'remaining',
        name: 'remaining',
        desc: '',
        args: [],
      );

  /// `(Saved)`
  String get savedSuffix => Intl.message(
        '(Saved)',
        name: 'savedSuffix',
        desc: '',
        args: [],
      );

  /// `Current Location`
  String get currentLocationFallback => Intl.message(
        'Current Location',
        name: 'currentLocationFallback',
        desc: '',
        args: [],
      );

  String get weekdayMonday => Intl.message('Monday', name: 'weekdayMonday');
  String get weekdayTuesday => Intl.message('Tuesday', name: 'weekdayTuesday');
  String get weekdayWednesday =>
      Intl.message('Wednesday', name: 'weekdayWednesday');
  String get weekdayThursday =>
      Intl.message('Thursday', name: 'weekdayThursday');
  String get weekdayFriday => Intl.message('Friday', name: 'weekdayFriday');
  String get weekdaySaturday =>
      Intl.message('Saturday', name: 'weekdaySaturday');
  String get weekdaySunday => Intl.message('Sunday', name: 'weekdaySunday');

  String get prayerFajr => Intl.message('Fajr', name: 'prayerFajr');
  String get prayerSunrise => Intl.message('Sunrise', name: 'prayerSunrise');
  String get prayerDhuhr => Intl.message('Dhuhr', name: 'prayerDhuhr');
  String get prayerAsr => Intl.message('Asr', name: 'prayerAsr');
  String get prayerMaghrib => Intl.message('Maghrib', name: 'prayerMaghrib');
  String get prayerIsha => Intl.message('Isha', name: 'prayerIsha');

  String get errorNoSavedManualLocation => Intl.message(
        'No saved manual location found. Please select a location in Settings.',
        name: 'errorNoSavedManualLocation',
      );

  String get errorManualLocationIncomplete => Intl.message(
        'Saved manual location details are incomplete.',
        name: 'errorManualLocationIncomplete',
      );

  String get errorCurrentLocationUnavailable => Intl.message(
        'Could not obtain current location. Please check GPS settings or connection.',
        name: 'errorCurrentLocationUnavailable',
      );

  String get errorNoPrayerTimes => Intl.message(
        'No prayer times available.',
        name: 'errorNoPrayerTimes',
      );

  String get settingsTitle => Intl.message('Settings', name: 'settingsTitle');
  String get settingsSectionTheme =>
      Intl.message('Theme', name: 'settingsSectionTheme');
  String get settingsThemeLight =>
      Intl.message('Light', name: 'settingsThemeLight');
  String get settingsThemeDark =>
      Intl.message('Dark', name: 'settingsThemeDark');
  String get settingsThemeSystem =>
      Intl.message('Device', name: 'settingsThemeSystem');
  String get settingsSectionLanguage =>
      Intl.message('Language', name: 'settingsSectionLanguage');
  String get settingsLanguageEnglish =>
      Intl.message('English', name: 'settingsLanguageEnglish');
  String get settingsLanguageArabic =>
      Intl.message('Arabic', name: 'settingsLanguageArabic');
  String get settingsSectionLocation =>
      Intl.message('Location', name: 'settingsSectionLocation');
  String get settingsLocationTitle =>
      Intl.message('Location', name: 'settingsLocationTitle');
  String get settingsLocationDescription => Intl.message(
        'Choose your location for accurate prayer times.',
        name: 'settingsLocationDescription',
      );
  String get settingsPermissionsTitle =>
      Intl.message('Permissions', name: 'settingsPermissionsTitle');
  String get settingsPermissionsDescription =>
      Intl.message('Manage app permissions',
          name: 'settingsPermissionsDescription');
  String get settingsAboutTitle =>
      Intl.message('About Nidaa', name: 'settingsAboutTitle');
  String get settingsAboutDescription => Intl.message(
        'App information, privacy, and more',
        name: 'settingsAboutDescription',
      );

  String get manualLocationTitle =>
      Intl.message('Location Options', name: 'manualLocationTitle');
  String get manualLocationUseCurrent => Intl.message(
        'Use Current Location',
        name: 'manualLocationUseCurrent',
      );
  String get manualLocationUseCurrentSubtitle => Intl.message(
        'Automatically fetch prayer times using GPS',
        name: 'manualLocationUseCurrentSubtitle',
      );
  String get manualLocationDetailsHeader => Intl.message(
        'Manual Location Details',
        name: 'manualLocationDetailsHeader',
      );
  String get manualLocationCountry =>
      Intl.message('Country', name: 'manualLocationCountry');
  String get manualLocationState => Intl.message(
        'State / Governorate / Province',
        name: 'manualLocationState',
      );
  String get manualLocationCity =>
      Intl.message('City', name: 'manualLocationCity');

  String manualLocationSelect(String label) => Intl.message(
        'Select $label',
        name: 'manualLocationSelect',
        args: [label],
      );

  String get manualLocationSaveButton =>
      Intl.message('Save Location Settings',
          name: 'manualLocationSaveButton');
  String get manualLocationSelectCountry =>
      Intl.message('Select Country', name: 'manualLocationSelectCountry');
  String get manualLocationSelectState => Intl.message(
        'Select State / Governorate',
        name: 'manualLocationSelectState',
      );
  String get manualLocationSelectCity =>
      Intl.message('Select City', name: 'manualLocationSelectCity');
  String get manualLocationFailedStates =>
      Intl.message('Failed to load states',
          name: 'manualLocationFailedStates');
  String get manualLocationFailedCities =>
      Intl.message('Failed to load cities',
          name: 'manualLocationFailedCities');
  String get manualLocationValidationError => Intl.message(
        'Please select Country, State, and City before saving.',
        name: 'manualLocationValidationError',
      );
  String get manualLocationSearchHint =>
      Intl.message('Search...', name: 'manualLocationSearchHint');
  String get manualLocationNoResults =>
      Intl.message('No results found', name: 'manualLocationNoResults');
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}