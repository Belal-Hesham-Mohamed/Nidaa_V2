class PrayerTimesApiConstants {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  static String timingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) {
    return '$baseUrl/timings/$date'
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
    return '$baseUrl/calendar/$year/$month'
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
    return '$baseUrl/timingsByCity/$date'
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
    return '$baseUrl/calendarByCity/$year/$month'
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
    return '$baseUrl/timingsByAddress/$date'
        '?address=$state, $country'
        '&method=5';
  }

  static String calendarByAddress({
    required String state,
    required String country,
    required int month,
    required int year,
  }) {
    return '$baseUrl/calendarByAddress/$year/$month'
        '?address=$state, $country'
        '&method=5';
  }
}
