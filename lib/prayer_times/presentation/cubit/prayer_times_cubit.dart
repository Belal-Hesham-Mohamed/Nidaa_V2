import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_mode_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_saved_current_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_saved_manual_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_manual_location_usecase.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_prayer_times_with_cache_usecase.dart';
import 'package:nidaa_v2/prayer_times/data/notifications/prayer_notification_service.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final GetLocationModeUsecase _getLocationModeUsecase;
  final GetLocationUsecase _getLocationUsecase;
  final GetSavedCurrentLocationUsecase _getSavedCurrentLocationUsecase;
  final GetSavedManualLocationUsecase _getSavedManualLocationUsecase;
  final GetManualLocationUsecase _getManualLocationUsecase;
  final GetPrayerTimesWithCacheUsecase _getPrayerTimesWithCacheUsecase;
  final PrayerNotificationService? _notificationService;

  PrayerTimesCubit(
    this._getLocationModeUsecase,
    this._getLocationUsecase,
    this._getSavedCurrentLocationUsecase,
    this._getSavedManualLocationUsecase,
    this._getManualLocationUsecase,
    this._getPrayerTimesWithCacheUsecase, [
    this._notificationService,
  ]) : super(PrayerTimesInitial());

  Future<void> getPrayerTimes() async {
    emit(PrayerTimesLoading());

    final modeResult = await _getLocationModeUsecase();
    final mode = modeResult.fold(
      (_) => LocationMode.current,
      (savedMode) => savedMode,
    );

    final now = DateTime.now();

    if (mode == LocationMode.manual) {
      final manualLocationResult = await _getSavedManualLocationUsecase();
      await manualLocationResult.fold(
        (failure) async {
          emit(PrayerTimesFailure(PrayerTimesErrorKey.noSavedManualLocation));
        },
        (manualLocation) async {
          var locationForCalculation = manualLocation;
          final city = locationForCalculation.city ?? '';
          final state = locationForCalculation.state ?? '';
          final country = locationForCalculation.country ?? '';

          if (city.isEmpty && state.isEmpty && country.isEmpty) {
            emit(
              PrayerTimesFailure(PrayerTimesErrorKey.manualLocationIncomplete),
            );
            return;
          }

          if (locationForCalculation.latitude == null ||
              locationForCalculation.longitude == null) {
            final resolution = await _getManualLocationUsecase(
              country: country,
              state: state,
              city: city,
            );
            final upgraded = resolution.fold((_) => null, (location) => location);
            if (upgraded == null) {
              emit(
                PrayerTimesFailure(PrayerTimesErrorKey.manualLocationIncomplete),
              );
              return;
            }
            locationForCalculation = upgraded;
          }

          final locationNameParts = <String>[];
          if (city.isNotEmpty) locationNameParts.add(city);
          if (state.isNotEmpty && state != city) locationNameParts.add(state);
          if (country.isNotEmpty) locationNameParts.add(country);
          final locationName = locationNameParts.join(', ');

          final daysResult = await _getPrayerTimesWithCacheUsecase(
            today: now,
            latitude: locationForCalculation.latitude!,
            longitude: locationForCalculation.longitude!,
          );
          await daysResult.fold(
            (failure) async => emit(
              PrayerTimesFailure(
                PrayerTimesErrorKey.unknown,
                rawMessage: failure.message,
              ),
            ),
            (days) async {
              if (days.length <= 7) {
                emit(PrayerTimesFailure(PrayerTimesErrorKey.noPrayerTimes));
                return;
              }
              if (_notificationService != null) {
                await _notificationService.reschedule(
                  days: days,
                  sound: PrayerNotificationSound.systemDefault,
                );
              }
              emit(
                PrayerTimesSuccess(
                  prayerTimes: days[7],
                  locationName: locationName,
                  isFallbackLocation: false,
                ),
              );
            },
          );
        },
      );
      return;
    }

    Location? previousLocation;
    final prevResult = await _getSavedCurrentLocationUsecase();
    prevResult.fold((_) {}, (loc) => previousLocation = loc);

    Location? location;
    bool isFallback = false;

    final freshLocationResult = await _getLocationUsecase();
    freshLocationResult.fold(
      (failure) => isFallback = true,
      (freshLoc) => location = freshLoc,
    );

    location ??= previousLocation;

    if (location == null) {
      emit(PrayerTimesFailure(PrayerTimesErrorKey.currentLocationUnavailable));
      return;
    }

    final locationNameParts = <String>[];
    if (location!.city != null && location!.city!.isNotEmpty) {
      locationNameParts.add(location!.city!);
    }
    if (location!.country != null && location!.country!.isNotEmpty) {
      locationNameParts.add(location!.country!);
    }
    final locationName = locationNameParts.isNotEmpty
        ? locationNameParts.join(', ')
        : 'Current Location';

    bool isMeaningfullyChanged = false;
    if (previousLocation != null && !isFallback) {
      isMeaningfullyChanged = !_isSameLocation(previousLocation!, location!);
    }

    Future<void> emitWithPrayerTimes(
      PrayerTimes prayerTimes, {
      bool fallback = false,
    }) async {
      final currentLocation = location;
      if (_notificationService != null && currentLocation != null) {
        final daysResult = await _getPrayerTimesWithCacheUsecase(
          today: now,
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        );
        await daysResult.fold(
          (_) async {},
          (days) => _notificationService.reschedule(
            days: days,
            sound: PrayerNotificationSound.systemDefault,
          ),
        );
      }
      emit(
        PrayerTimesSuccess(
          prayerTimes: prayerTimes,
          locationName: locationName,
          currentLocation: location,
          isFallbackLocation: fallback,
        ),
      );
    }

    if (isMeaningfullyChanged) {
      final replaceResult = await _getPrayerTimesWithCacheUsecase.replaceCache(
        today: now,
        latitude: location!.latitude,
        longitude: location!.longitude,
      );

      await replaceResult.fold(
        (failure) async {
          final fallbackCacheResult = await _getPrayerTimesWithCacheUsecase(
            today: now,
            latitude: location!.latitude,
            longitude: location!.longitude,
          );

          fallbackCacheResult.fold(
            (_) => emit(
              PrayerTimesFailure(
                PrayerTimesErrorKey.unknown,
                rawMessage: failure.message,
              ),
            ),
            (prayerTimesList) {
              if (prayerTimesList.isEmpty) {
                emit(
                  PrayerTimesFailure(
                    PrayerTimesErrorKey.unknown,
                    rawMessage: failure.message,
                  ),
                );
                return;
              }
              final todayPrayerTimes = _findTodayPrayerTimes(prayerTimesList);
              if (todayPrayerTimes == null) {
                emit(PrayerTimesFailure(PrayerTimesErrorKey.noPrayerTimes));
                return;
              }
              emitWithPrayerTimes(todayPrayerTimes, fallback: true);
            },
          );
        },
        (newPrayerTimesList) {
          final todayPrayerTimes = _findTodayPrayerTimes(newPrayerTimesList);
          if (todayPrayerTimes == null) {
            emit(PrayerTimesFailure(PrayerTimesErrorKey.noPrayerTimes));
            return;
          }
          emitWithPrayerTimes(todayPrayerTimes, fallback: isFallback);
        },
      );
    } else {
      final cachedListResult = await _getPrayerTimesWithCacheUsecase(
        today: now,
        latitude: location!.latitude,
        longitude: location!.longitude,
      );

      cachedListResult.fold(
        (failure) => emit(
          PrayerTimesFailure(
            PrayerTimesErrorKey.unknown,
            rawMessage: failure.message,
          ),
        ),
        (prayerTimesList) {
          if (prayerTimesList.isEmpty) {
            emit(PrayerTimesFailure(PrayerTimesErrorKey.noPrayerTimes));
            return;
          }
          final todayPrayerTimes = _findTodayPrayerTimes(prayerTimesList);
          if (todayPrayerTimes == null) {
            emit(PrayerTimesFailure(PrayerTimesErrorKey.noPrayerTimes));
            return;
          }
          emitWithPrayerTimes(todayPrayerTimes, fallback: isFallback);
        },
      );
    }
  }

  bool _isSameLocation(Location oldLocation, Location newLocation) {
    final oldCountry = _normalize(oldLocation.country);
    final newCountry = _normalize(newLocation.country);
    if (oldCountry.isNotEmpty &&
        newCountry.isNotEmpty &&
        oldCountry != newCountry) {
      return false;
    }

    final oldCity = _normalize(oldLocation.city);
    final newCity = _normalize(newLocation.city);
    final oldAdministrativeArea = _normalize(oldLocation.administrativeArea);
    final newAdministrativeArea = _normalize(newLocation.administrativeArea);
    final oldSubLocality = _normalize(oldLocation.subLocality);
    final newSubLocality = _normalize(newLocation.subLocality);

    final hasTextMatch =
        (oldCity.isNotEmpty && newCity.isNotEmpty && oldCity == newCity) ||
        (oldAdministrativeArea.isNotEmpty &&
            newAdministrativeArea.isNotEmpty &&
            oldAdministrativeArea == newAdministrativeArea) ||
        (oldSubLocality.isNotEmpty &&
            newSubLocality.isNotEmpty &&
            oldSubLocality == newSubLocality);

    if (hasTextMatch) return true;

    final distanceInMeters = Geolocator.distanceBetween(
      oldLocation.latitude,
      oldLocation.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );

    const gpsThresholdInMeters = 100;
    return distanceInMeters < gpsThresholdInMeters;
  }

  String _normalize(String? value) => value?.trim().toLowerCase() ?? '';

  PrayerTimes? _findTodayPrayerTimes(List<PrayerTimes> list) {
    // The repository returns seven past dates, the location's current day,
    // and seven future dates in that location's IANA timezone.
    if (list.length > 7) return list[7];
    final now = DateTime.now();
    final dateHyphen = DateFormat('dd-MM-yyyy').format(now);
    final dateReadable1 = DateFormat('dd MMM yyyy').format(now);
    final dateReadable2 = DateFormat('d MMM yyyy').format(now);

    for (final pt in list) {
      final g = pt.date.gregorian.trim();
      if (g == dateHyphen || g == dateReadable1 || g == dateReadable2) {
        return pt;
      }
    }

    for (final pt in list) {
      final g = pt.date.gregorian.trim();
      if (g.contains('-')) {
        final parts = g.split('-');
        if (parts.length >= 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day == now.day && month == now.month && year == now.year) {
            return pt;
          }
        }
      }
    }

    return null;
  }
}
