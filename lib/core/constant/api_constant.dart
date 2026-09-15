import 'package:nidaa_v2/core/config/app_config.dart';

class ApiConstants {
  /// Points at the centralized base URL. Request paths below are relative to
  /// it and must not repeat the host.
  static const String baseUrl = AppConfig.apiBaseUrl;

  static String timingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) {
    return '/timings/$date'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=5';
  }

  static String calendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) {
    return '/calendar/$year/$month'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=5';
  }

  static String timingsByCity({
    required String city,
    required String state,
    required String country,
    required String date,
  }) {
    return '/timingsByCity/$date'
        '?city=$city'
        '&state=$state'
        '&country=$country'
        '&method=5';
  }

  static String calendarByCity({
    required String city,
    required String state,
    required String country,
    required int month,
    required int year,
  }) {
    return '/calendarByCity/$year/$month'
        '?city=$city'
        '&state=$state'
        '&country=$country'
        '&method=5';
  }

  static String timingsByAddress({
    required String state,
    required String country,
    required String date,
  }) {
    return '/timingsByAddress/$date'
        '?address=$state, $country'
        '&method=5';
  }

  static String calendarByAddress({
    required String state,
    required String country,
    required int month,
    required int year,
  }) {
    return '/calendarByAddress/$year/$month'
        '?address=$state, $country'
        '&method=5';
  }
}
