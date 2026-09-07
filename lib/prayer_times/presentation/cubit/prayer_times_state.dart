part of 'prayer_times_cubit.dart';

@immutable
sealed class PrayerTimesState {}

final class PrayerTimesInitial extends PrayerTimesState {}

final class PrayerTimesLoading extends PrayerTimesState {}

final class PrayerTimesSuccess extends PrayerTimesState {
  final PrayerTimes prayerTimes;
  final String locationName;
  final Location? currentLocation;
  final bool isFallbackLocation;

  PrayerTimesSuccess({
    required this.prayerTimes,
    required this.locationName,
    this.currentLocation,
    this.isFallbackLocation = false,
  });
}

enum PrayerTimesErrorKey {
  noSavedManualLocation,
  manualLocationIncomplete,
  currentLocationUnavailable,
  noPrayerTimes,
  unknown,
}

final class PrayerTimesFailure extends PrayerTimesState {
  final PrayerTimesErrorKey errorKey;
  final String? rawMessage;

  PrayerTimesFailure(this.errorKey, {this.rawMessage});
}