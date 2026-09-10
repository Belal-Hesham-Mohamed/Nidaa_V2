import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/qibla/domain/qibla_angle.dart';
import 'package:nidaa_v2/qibla/domain/usecase/calculate_qibla_bearing_usecase.dart';

part 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  final CalculateQiblaBearingUseCase _calculateQiblaBearingUseCase;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double? _qiblaBearing;
  double? _deviceHeading;

  // A light circular low-pass filter removes magnetometer jitter without
  // making normal phone rotation feel delayed.
  static const _headingSmoothingFactor = 0.25;

  QiblaCubit(this._calculateQiblaBearingUseCase) : super(QiblaInitial()) {
    // The Cubit owns the one sensor subscription for its entire lifetime.
    // It is deliberately started here, never from a widget build method.
    _subscribeToCompass();
  }

  void _subscribeToCompass() {
    final compassEvents = FlutterCompass.events;
    if (compassEvents == null) {
      emit(QiblaFailure(QiblaErrorKey.compassUnavailable));
      return;
    }

    _compassSubscription = compassEvents.listen(
      _onCompassEvent,
      onError: (_, _) => emit(QiblaFailure(QiblaErrorKey.compassError)),
    );
  }

  void _onCompassEvent(CompassEvent event) {
    final heading = event.heading;
    // flutter_compass can report null while the platform sensor is not ready.
    // Do not replace a good reading with an error or a fake number.
    if (heading == null || !heading.isFinite) return;

    final normalizedHeading = QiblaAngle.normalize(heading);
    final previousHeading = _deviceHeading;
    if (previousHeading == null) {
      _deviceHeading = normalizedHeading;
    } else {
      final delta = QiblaAngle.shortestDifference(
        normalizedHeading,
        previousHeading,
      );
      _deviceHeading = QiblaAngle.normalize(
        previousHeading + delta * _headingSmoothingFactor,
      );
    }
    _emitSuccessIfReady();
  }

  void _emitSuccessIfReady() {
    final qiblaBearing = _qiblaBearing;
    final deviceHeading = _deviceHeading;
    if (qiblaBearing == null) return;

    if (deviceHeading == null) {
      emit(QiblaSuccess(qiblaBearing: qiblaBearing));
      return;
    }

    final relativeAngle = QiblaAngle.normalize(qiblaBearing - deviceHeading);
    final shortestAngle = QiblaAngle.shortestDifference(
      qiblaBearing,
      deviceHeading,
    );
    emit(
      QiblaSuccess(
        qiblaBearing: qiblaBearing,
        deviceHeading: deviceHeading,
        relativeAngle: relativeAngle,
        shortestAngle: shortestAngle,
        isAligned: shortestAngle.abs() <= 5.0,
      ),
    );
  }

  void calculateQiblaBearing(Location? location) {
    // Location is loaded once by the screen. Updating it must not put an
    // already initialized compass back into a loading state.
    if (_qiblaBearing == null) emit(QiblaLoading());

    if (location == null) {
      emit(QiblaFailure(QiblaErrorKey.locationUnavailable));
      return;
    }

    final latitude = location.latitude;
    final longitude = location.longitude;
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      emit(QiblaFailure(QiblaErrorKey.invalidCoordinates));
      return;
    }

    final bearing = _calculateQiblaBearingUseCase(
      latitude: latitude,
      longitude: longitude,
    );
    if (!bearing.isFinite) {
      emit(QiblaFailure(QiblaErrorKey.invalidCoordinates));
      return;
    }

    _qiblaBearing = QiblaAngle.normalize(bearing);
    _emitSuccessIfReady();
  }

  @override
  Future<void> close() async {
    await _compassSubscription?.cancel();
    return super.close();
  }
}
