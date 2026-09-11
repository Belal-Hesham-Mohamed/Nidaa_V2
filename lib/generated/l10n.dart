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
  String get appTitle {
    return Intl.message('Nidaa', name: 'appTitle', desc: '', args: []);
  }

  /// `Prayer Times`
  String get navPrayerTimes {
    return Intl.message(
      'Prayer Times',
      name: 'navPrayerTimes',
      desc: '',
      args: [],
    );
  }

  /// `Qibla`
  String get navQibla {
    return Intl.message('Qibla', name: 'navQibla', desc: '', args: []);
  }

  /// `Azkar`
  String get navAzkar {
    return Intl.message('Azkar', name: 'navAzkar', desc: '', args: []);
  }

  /// `Settings`
  String get navSettings {
    return Intl.message('Settings', name: 'navSettings', desc: '', args: []);
  }

  /// `Strengthen your day with the remembrance of Allah`
  String get azkarHeader {
    return Intl.message(
      'Strengthen your day with the remembrance of Allah',
      name: 'azkarHeader',
      desc: '',
      args: [],
    );
  }

  /// `Azkar`
  String get azkarSectionTitle {
    return Intl.message('Azkar', name: 'azkarSectionTitle', desc: '', args: []);
  }

  /// `Time for Dhikr Now`
  String get azkarNow {
    return Intl.message(
      'Time for Dhikr Now',
      name: 'azkarNow',
      desc: '',
      args: [],
    );
  }

  /// `No specific dhikr time now`
  String get azkarNoCurrentTime {
    return Intl.message(
      'No specific dhikr time now',
      name: 'azkarNoCurrentTime',
      desc: '',
      args: [],
    );
  }

  /// `Morning Azkar`
  String get azkarMorning {
    return Intl.message(
      'Morning Azkar',
      name: 'azkarMorning',
      desc: '',
      args: [],
    );
  }

  /// `Evening Azkar`
  String get azkarEvening {
    return Intl.message(
      'Evening Azkar',
      name: 'azkarEvening',
      desc: '',
      args: [],
    );
  }

  /// `Sleep Azkar`
  String get azkarSleep {
    return Intl.message('Sleep Azkar', name: 'azkarSleep', desc: '', args: []);
  }

  /// `Prayer Azkar`
  String get azkarPrayer {
    return Intl.message(
      'Prayer Azkar',
      name: 'azkarPrayer',
      desc: '',
      args: [],
    );
  }

  /// `Duas`
  String get azkarDuas {
    return Intl.message('Duas', name: 'azkarDuas', desc: '', args: []);
  }

  /// `Toilet Etiquette Azkar`
  String get azkarToilet {
    return Intl.message(
      'Toilet Etiquette Azkar',
      name: 'azkarToilet',
      desc: '',
      args: [],
    );
  }

  /// `Daily Azkar`
  String get azkarDaily {
    return Intl.message('Daily Azkar', name: 'azkarDaily', desc: '', args: []);
  }

  /// `After Fajr until sunrise`
  String get azkarMorningWindow {
    return Intl.message(
      'After Fajr until sunrise',
      name: 'azkarMorningWindow',
      desc: '',
      args: [],
    );
  }

  /// `After Asr until Maghrib`
  String get azkarEveningWindow {
    return Intl.message(
      'After Asr until Maghrib',
      name: 'azkarEveningWindow',
      desc: '',
      args: [],
    );
  }

  /// `items`
  String get azkarItems {
    return Intl.message('items', name: 'azkarItems', desc: '', args: []);
  }

  /// `Progress`
  String get progress {
    return Intl.message('Progress', name: 'progress', desc: '', args: []);
  }

  /// `Source`
  String get source {
    return Intl.message('Source', name: 'source', desc: '', args: []);
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Tap to count`
  String get tapToCount {
    return Intl.message('Tap to count', name: 'tapToCount', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Coming Soon`
  String get comingSoon {
    return Intl.message('Coming Soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `remaining`
  String get remaining {
    return Intl.message('remaining', name: 'remaining', desc: '', args: []);
  }

  /// `(Saved)`
  String get savedSuffix {
    return Intl.message('(Saved)', name: 'savedSuffix', desc: '', args: []);
  }

  /// `Current Location`
  String get currentLocationFallback {
    return Intl.message(
      'Current Location',
      name: 'currentLocationFallback',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get weekdayMonday {
    return Intl.message('Monday', name: 'weekdayMonday', desc: '', args: []);
  }

  /// `Tuesday`
  String get weekdayTuesday {
    return Intl.message('Tuesday', name: 'weekdayTuesday', desc: '', args: []);
  }

  /// `Wednesday`
  String get weekdayWednesday {
    return Intl.message(
      'Wednesday',
      name: 'weekdayWednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get weekdayThursday {
    return Intl.message(
      'Thursday',
      name: 'weekdayThursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get weekdayFriday {
    return Intl.message('Friday', name: 'weekdayFriday', desc: '', args: []);
  }

  /// `Saturday`
  String get weekdaySaturday {
    return Intl.message(
      'Saturday',
      name: 'weekdaySaturday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday`
  String get weekdaySunday {
    return Intl.message('Sunday', name: 'weekdaySunday', desc: '', args: []);
  }

  /// `Fajr`
  String get prayerFajr {
    return Intl.message('Fajr', name: 'prayerFajr', desc: '', args: []);
  }

  /// `Sunrise`
  String get prayerSunrise {
    return Intl.message('Sunrise', name: 'prayerSunrise', desc: '', args: []);
  }

  /// `Dhuhr`
  String get prayerDhuhr {
    return Intl.message('Dhuhr', name: 'prayerDhuhr', desc: '', args: []);
  }

  /// `Asr`
  String get prayerAsr {
    return Intl.message('Asr', name: 'prayerAsr', desc: '', args: []);
  }

  /// `Maghrib`
  String get prayerMaghrib {
    return Intl.message('Maghrib', name: 'prayerMaghrib', desc: '', args: []);
  }

  /// `Isha`
  String get prayerIsha {
    return Intl.message('Isha', name: 'prayerIsha', desc: '', args: []);
  }

  /// `No saved manual location found. Please select a location in Settings.`
  String get errorNoSavedManualLocation {
    return Intl.message(
      'No saved manual location found. Please select a location in Settings.',
      name: 'errorNoSavedManualLocation',
      desc: '',
      args: [],
    );
  }

  /// `Saved manual location details are incomplete.`
  String get errorManualLocationIncomplete {
    return Intl.message(
      'Saved manual location details are incomplete.',
      name: 'errorManualLocationIncomplete',
      desc: '',
      args: [],
    );
  }

  /// `Could not obtain current location. Please check GPS settings or connection.`
  String get errorCurrentLocationUnavailable {
    return Intl.message(
      'Could not obtain current location. Please check GPS settings or connection.',
      name: 'errorCurrentLocationUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `No prayer times available.`
  String get errorNoPrayerTimes {
    return Intl.message(
      'No prayer times available.',
      name: 'errorNoPrayerTimes',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message('Settings', name: 'settingsTitle', desc: '', args: []);
  }

  /// `Theme`
  String get settingsSectionTheme {
    return Intl.message(
      'Theme',
      name: 'settingsSectionTheme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get settingsThemeLight {
    return Intl.message(
      'Light',
      name: 'settingsThemeLight',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get settingsThemeDark {
    return Intl.message('Dark', name: 'settingsThemeDark', desc: '', args: []);
  }

  /// `Device`
  String get settingsThemeSystem {
    return Intl.message(
      'Device',
      name: 'settingsThemeSystem',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settingsSectionLanguage {
    return Intl.message(
      'Language',
      name: 'settingsSectionLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get settingsLanguageEnglish {
    return Intl.message(
      'English',
      name: 'settingsLanguageEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get settingsLanguageArabic {
    return Intl.message(
      'Arabic',
      name: 'settingsLanguageArabic',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get settingsSectionLocation {
    return Intl.message(
      'Location',
      name: 'settingsSectionLocation',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get settingsLocationTitle {
    return Intl.message(
      'Location',
      name: 'settingsLocationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose your location for accurate prayer times.`
  String get settingsLocationDescription {
    return Intl.message(
      'Choose your location for accurate prayer times.',
      name: 'settingsLocationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Permissions`
  String get settingsPermissionsTitle {
    return Intl.message(
      'Permissions',
      name: 'settingsPermissionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Manage app permissions`
  String get settingsPermissionsDescription {
    return Intl.message(
      'Manage app permissions',
      name: 'settingsPermissionsDescription',
      desc: '',
      args: [],
    );
  }

  /// `About Nidaa`
  String get settingsAboutTitle {
    return Intl.message(
      'About Nidaa',
      name: 'settingsAboutTitle',
      desc: '',
      args: [],
    );
  }

  /// `App information, privacy, and more`
  String get settingsAboutDescription {
    return Intl.message(
      'App information, privacy, and more',
      name: 'settingsAboutDescription',
      desc: '',
      args: [],
    );
  }

  /// `Location Options`
  String get manualLocationTitle {
    return Intl.message(
      'Location Options',
      name: 'manualLocationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use Current Location`
  String get manualLocationUseCurrent {
    return Intl.message(
      'Use Current Location',
      name: 'manualLocationUseCurrent',
      desc: '',
      args: [],
    );
  }

  /// `Automatically fetch prayer times using GPS`
  String get manualLocationUseCurrentSubtitle {
    return Intl.message(
      'Automatically fetch prayer times using GPS',
      name: 'manualLocationUseCurrentSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Manual Location Details`
  String get manualLocationDetailsHeader {
    return Intl.message(
      'Manual Location Details',
      name: 'manualLocationDetailsHeader',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get manualLocationCountry {
    return Intl.message(
      'Country',
      name: 'manualLocationCountry',
      desc: '',
      args: [],
    );
  }

  /// `State / Governorate / Province`
  String get manualLocationState {
    return Intl.message(
      'State / Governorate / Province',
      name: 'manualLocationState',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get manualLocationCity {
    return Intl.message('City', name: 'manualLocationCity', desc: '', args: []);
  }

  /// `Select {label}`
  String manualLocationSelect(String label) {
    return Intl.message(
      'Select $label',
      name: 'manualLocationSelect',
      desc: '',
      args: [label],
    );
  }

  /// `Save Location Settings`
  String get manualLocationSaveButton {
    return Intl.message(
      'Save Location Settings',
      name: 'manualLocationSaveButton',
      desc: '',
      args: [],
    );
  }

  /// `Select Country`
  String get manualLocationSelectCountry {
    return Intl.message(
      'Select Country',
      name: 'manualLocationSelectCountry',
      desc: '',
      args: [],
    );
  }

  /// `Select State / Governorate`
  String get manualLocationSelectState {
    return Intl.message(
      'Select State / Governorate',
      name: 'manualLocationSelectState',
      desc: '',
      args: [],
    );
  }

  /// `Select City`
  String get manualLocationSelectCity {
    return Intl.message(
      'Select City',
      name: 'manualLocationSelectCity',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load states`
  String get manualLocationFailedStates {
    return Intl.message(
      'Failed to load states',
      name: 'manualLocationFailedStates',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load cities`
  String get manualLocationFailedCities {
    return Intl.message(
      'Failed to load cities',
      name: 'manualLocationFailedCities',
      desc: '',
      args: [],
    );
  }

  /// `Please select Country, State, and City before saving.`
  String get manualLocationValidationError {
    return Intl.message(
      'Please select Country, State, and City before saving.',
      name: 'manualLocationValidationError',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get manualLocationSearchHint {
    return Intl.message(
      'Search...',
      name: 'manualLocationSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get manualLocationNoResults {
    return Intl.message(
      'No results found',
      name: 'manualLocationNoResults',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get onboardingSkip {
    return Intl.message('Skip', name: 'onboardingSkip', desc: '', args: []);
  }

  /// `Next`
  String get onboardingNext {
    return Intl.message('Next', name: 'onboardingNext', desc: '', args: []);
  }

  /// `Get Started`
  String get onboardingGetStarted {
    return Intl.message(
      'Get Started',
      name: 'onboardingGetStarted',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Nidaa`
  String get onboardingWelcomeTitle {
    return Intl.message(
      'Welcome to Nidaa',
      name: 'onboardingWelcomeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your companion for prayer times, Qibla direction, and daily Azkar.`
  String get onboardingWelcomeDescription {
    return Intl.message(
      'Your companion for prayer times, Qibla direction, and daily Azkar.',
      name: 'onboardingWelcomeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Never Miss a Prayer`
  String get onboardingPrayerTitle {
    return Intl.message(
      'Never Miss a Prayer',
      name: 'onboardingPrayerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Stay connected to your prayers with accurate prayer times based on your location.`
  String get onboardingPrayerDescription {
    return Intl.message(
      'Stay connected to your prayers with accurate prayer times based on your location.',
      name: 'onboardingPrayerDescription',
      desc: '',
      args: [],
    );
  }

  /// `Find the Qibla`
  String get onboardingQiblaTitle {
    return Intl.message(
      'Find the Qibla',
      name: 'onboardingQiblaTitle',
      desc: '',
      args: [],
    );
  }

  /// `Easily find the direction of the Kaaba wherever you are.`
  String get onboardingQiblaDescription {
    return Intl.message(
      'Easily find the direction of the Kaaba wherever you are.',
      name: 'onboardingQiblaDescription',
      desc: '',
      args: [],
    );
  }

  /// `Remember Allah`
  String get onboardingAzkarTitle {
    return Intl.message(
      'Remember Allah',
      name: 'onboardingAzkarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Keep your daily Azkar close and make remembrance of Allah part of your day.`
  String get onboardingAzkarDescription {
    return Intl.message(
      'Keep your daily Azkar close and make remembrance of Allah part of your day.',
      name: 'onboardingAzkarDescription',
      desc: '',
      args: [],
    );
  }

  /// `Ready to Begin?`
  String get onboardingReadyTitle {
    return Intl.message(
      'Ready to Begin?',
      name: 'onboardingReadyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Start your journey with Nidaa and make every prayer count.`
  String get onboardingReadyDescription {
    return Intl.message(
      'Start your journey with Nidaa and make every prayer count.',
      name: 'onboardingReadyDescription',
      desc: '',
      args: [],
    );
  }
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
