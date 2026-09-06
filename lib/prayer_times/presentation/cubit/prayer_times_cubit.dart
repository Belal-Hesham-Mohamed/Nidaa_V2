import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location_mode.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_mode_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_saved_current_location_usecase.dart';
import 'package:nidaa_v2/location/manual_location/domain/usecase/get_saved_manual_location_usecase.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_prayer_times_usecase.dart';
import 'package:nidaa_v2/prayer_times/domain/usecase/get_prayer_times_with_cache_usecase.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final GetLocationModeUsecase _getLocationModeUsecase;
  final GetLocationUsecase _getLocationUsecase;
  final GetSavedCurrentLocationUsecase _getSavedCurrentLocationUsecase;
  final GetSavedManualLocationUsecase _getSavedManualLocationUsecase;
  final GetPrayerTimesUsecase _getPrayerTimesUsecase;
  final GetPrayerTimesWithCacheUsecase _getPrayerTimesWithCacheUsecase;

  PrayerTimesCubit(
    this._getLocationModeUsecase,
    this._getLocationUsecase,
    this._getSavedCurrentLocationUsecase,
    this._getSavedManualLocationUsecase,
    this._getPrayerTimesUsecase,
    this._getPrayerTimesWithCacheUsecase,
  ) : super(PrayerTimesInitial());

  Future<void> getPrayerTimes() async {
    emit(PrayerTimesLoading());

    // 1. Determine location mode (Current vs Manual)
    final modeResult = await _getLocationModeUsecase();
    final mode = modeResult.fold(
      (_) => LocationMode.current,
      (savedMode) => savedMode,
    );

    final now = DateTime.now();
    final String dateStr = DateFormat('dd-MM-yyyy').format(now);

    if (mode == LocationMode.manual) {
      // Manual Mode: NEVER request GPS! Use saved manual location only.
      final manualLocationResult = await _getSavedManualLocationUsecase();
      await manualLocationResult.fold(
        (failure) async {
          emit(PrayerTimesFailure(
            'No saved manual location found. Please select a location in Settings.',
          ));
        },
        (manualLocation) async {
          final city = manualLocation.city ?? '';
          final state = manualLocation.state ?? '';
          final country = manualLocation.country ?? '';

          if (city.isEmpty && state.isEmpty && country.isEmpty) {
            emit(PrayerTimesFailure('Saved manual location details are incomplete.'));
            return;
          }

          final locationNameParts = <String>[];
          if (city.isNotEmpty) locationNameParts.add(city);
          if (state.isNotEmpty && state != city) locationNameParts.add(state);
          if (country.isNotEmpty) locationNameParts.add(country);
          final locationName = locationNameParts.join(', ');

          final prayerTimesResult = await _getPrayerTimesUsecase.getTimingsByCity(
            city: city,
            state: state,
            country: country,
            date: dateStr,
          );

          prayerTimesResult.fold(
            (failure) => emit(PrayerTimesFailure(failure.message)),
            (prayerTimes) => emit(
              PrayerTimesSuccess(
                prayerTimes: prayerTimes,
                locationName: locationName,
                isFallbackLocation: false,
              ),
            ),
          );
        },
      );
    } else {
      // Current Mode Flow:
      // 1. Get previously saved location before calling getLocation
      Location? previousLocation;
      final prevResult = await _getSavedCurrentLocationUsecase();
      prevResult.fold((_) {}, (loc) => previousLocation = loc);

      Location? location;
      bool isFallback = false;

      // 2. Fetch fresh GPS location using GetLocationUsecase
      final freshLocationResult = await _getLocationUsecase();
      freshLocationResult.fold(
        (failure) {
          isFallback = true;
        },
        (freshLoc) {
          location = freshLoc;
        },
      );

      if (location == null && previousLocation != null) {
        location = previousLocation;
      }

      if (location == null) {
        emit(PrayerTimesFailure(
          'Could not obtain current location. Please check GPS settings or connection.',
        ));
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

      // 3. Check if location meaningfully changed
      bool isMeaningfullyChanged = false;
      if (previousLocation != null && !isFallback) {
        isMeaningfullyChanged = _isLocationMeaningfullyChanged(previousLocation!, location!);
      }

      if (isMeaningfullyChanged) {
        // Location CHANGED:
        // Do NOT delete old cache first. Fetch prayer times for NEW location first.
        final newLocationResult = await _getPrayerTimesUsecase.getTimingsByCoordinates(
          latitude: location!.latitude,
          longitude: location!.longitude,
          date: dateStr,
        );

        await newLocationResult.fold(
          (failure) async {
            // API request failed -> keep old cache intact & use as fallback
            final fallbackCacheResult = await _getPrayerTimesWithCacheUsecase(
              today: now,
              latitude: location!.latitude,
              longitude: location!.longitude,
            );

            fallbackCacheResult.fold(
              (_) => emit(PrayerTimesFailure(failure.message)),
              (prayerTimesList) {
                if (prayerTimesList.isEmpty) {
                  emit(PrayerTimesFailure(failure.message));
                } else {
                  final todayPrayerTimes = _findTodayPrayerTimes(prayerTimesList);
                  emit(
                    PrayerTimesSuccess(
                      prayerTimes: todayPrayerTimes,
                      locationName: locationName,
                      isFallbackLocation: true,
                    ),
                  );
                }
              },
            );
          },
          (newPrayerTimes) async {
            // API SUCCESS -> update cache for the new location
            final cacheResult = await _getPrayerTimesWithCacheUsecase(
              today: now,
              latitude: location!.latitude,
              longitude: location!.longitude,
            );

            cacheResult.fold(
              (_) => emit(
                PrayerTimesSuccess(
                  prayerTimes: newPrayerTimes,
                  locationName: locationName,
                  isFallbackLocation: isFallback,
                ),
              ),
              (prayerTimesList) {
                final todayPrayerTimes = _findTodayPrayerTimes(prayerTimesList);
                emit(
                  PrayerTimesSuccess(
                    prayerTimes: todayPrayerTimes,
                    locationName: locationName,
                    isFallbackLocation: isFallback,
                  ),
                );
              },
            );
          },
        );
      } else {
        // Location UNCHANGED (or first launch / fallback):
        // Use GetPrayerTimesWithCacheUsecase.
        // If required cache exists, it does NOT call the Prayer Times API.
        // If cache is missing, it fetches only missing data and updates cache.
        final cachedListResult = await _getPrayerTimesWithCacheUsecase(
          today: now,
          latitude: location!.latitude,
          longitude: location!.longitude,
        );

        cachedListResult.fold(
          (failure) => emit(PrayerTimesFailure(failure.message)),
          (prayerTimesList) {
            if (prayerTimesList.isEmpty) {
              emit(PrayerTimesFailure('No prayer times available.'));
              return;
            }
            final todayPrayerTimes = _findTodayPrayerTimes(prayerTimesList);
            emit(
              PrayerTimesSuccess(
                prayerTimes: todayPrayerTimes,
                locationName: locationName,
                isFallbackLocation: isFallback,
              ),
            );
          },
        );
      }
    }
  }

  bool _isLocationMeaningfullyChanged(Location loc1, Location loc2) {
    final country1 = (loc1.country ?? '').trim().toLowerCase();
    final country2 = (loc2.country ?? '').trim().toLowerCase();
    if (country1.isNotEmpty && country2.isNotEmpty && country1 != country2) {
      return true;
    }

    final city1 = (loc1.city ?? '').trim().toLowerCase();
    final city2 = (loc2.city ?? '').trim().toLowerCase();
    if (city1.isNotEmpty && city2.isNotEmpty && city1 != city2) {
      return true;
    }

    final latDiff = (loc1.latitude - loc2.latitude).abs();
    final lngDiff = (loc1.longitude - loc2.longitude).abs();
    return latDiff > 0.05 || lngDiff > 0.05;
  }

  PrayerTimes _findTodayPrayerTimes(List<PrayerTimes> list) {
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

    return list.first;
  }
}