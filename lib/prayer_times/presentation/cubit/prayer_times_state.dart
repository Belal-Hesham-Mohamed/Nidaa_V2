part of 'prayer_times_cubit.dart';

@immutable
sealed class PrayerTimesState {}

final class PrayerTimesInitial extends PrayerTimesState {}

final class PrayerTimesLoading extends PrayerTimesState {}

final class PrayerTimesSuccess extends PrayerTimesState {
  final PrayerTimes prayerTimes;
  final String locationName;
  final bool isFallbackLocation;

  PrayerTimesSuccess({
    required this.prayerTimes,
    required this.locationName,
    this.isFallbackLocation = false,
  });
}

final class PrayerTimesFailure extends PrayerTimesState {
  final String message;

  PrayerTimesFailure(this.message);
}