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

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final GetLocationModeUsecase _getLocationModeUsecase;
  final GetLocationUsecase _getLocationUsecase;
  final GetSavedCurrentLocationUsecase _getSavedCurrentLocationUsecase;
  final GetSavedManualLocationUsecase _getSavedManualLocationUsecase;
  final GetPrayerTimesUsecase _getPrayerTimesUsecase;

  PrayerTimesCubit(
    this._getLocationModeUsecase,
    this._getLocationUsecase,
    this._getSavedCurrentLocationUsecase,
    this._getSavedManualLocationUsecase,
    this._getPrayerTimesUsecase,
  ) : super(PrayerTimesInitial());

  Future<void> getPrayerTimes() async {
    emit(PrayerTimesLoading());

    // 1. Determine location mode (Current vs Manual)
    final modeResult = await _getLocationModeUsecase();
    final mode = modeResult.fold(
      (_) => LocationMode.current,
      (savedMode) => savedMode,
    );

    final String date = DateFormat('dd-MM-yyyy').format(DateTime.now());

    if (mode == LocationMode.manual) {
      // Manual Mode: DO NOT request GPS! Use saved manual location only.
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
            date: date,
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
      // Current Mode:
      // First attempt to obtain fresh current location using GetLocationUsecase.
      Location? location;
      bool isFallback = false;

      final freshLocationResult = await _getLocationUsecase();
      freshLocationResult.fold(
        (failure) {
          // Fresh GPS failed -> mark as fallback needed
          isFallback = true;
        },
        (freshLoc) {
          location = freshLoc;
        },
      );

      if (location == null) {
        // Fetch saved current location as explicit fallback
        final savedLocationResult = await _getSavedCurrentLocationUsecase();
        savedLocationResult.fold(
          (failure) {},
          (savedLoc) {
            location = savedLoc;
          },
        );
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

      final prayerTimesResult = await _getPrayerTimesUsecase.getTimingsByCoordinates(
        latitude: location!.latitude,
        longitude: location!.longitude,
        date: date,
      );

      prayerTimesResult.fold(
        (failure) => emit(PrayerTimesFailure(failure.message)),
        (prayerTimes) => emit(
          PrayerTimesSuccess(
            prayerTimes: prayerTimes,
            locationName: locationName,
            isFallbackLocation: isFallback,
          ),
        ),
      );
    }
  }
}