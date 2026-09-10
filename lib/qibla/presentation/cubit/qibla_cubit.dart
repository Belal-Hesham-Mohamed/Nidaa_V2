import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/qibla/domain/usecase/calculate_qibla_bearing_usecase.dart';

part 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  final CalculateQiblaBearingUseCase _calculateQiblaBearingUseCase;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double? _qiblaBearing;
  double? _deviceHeading;

  QiblaCubit(this._calculateQiblaBearingUseCase) : super(QiblaInitial()) {
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
    if (heading == null || !heading.isFinite) {
      emit(QiblaFailure(QiblaErrorKey.headingUnavailable));
      return;
    }

    _deviceHeading = _normalizeAngle(heading);
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

    final relativeAngle = _normalizeAngle(qiblaBearing - deviceHeading);
    final shortestAngle = _shortestAngle(qiblaBearing, deviceHeading);
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

  double _normalizeAngle(double angle) {
    return (angle % 360 + 360) % 360;
  }

  double _shortestAngle(double targetAngle, double currentAngle) {
    final normalizedDifference = _normalizeAngle(targetAngle - currentAngle);
    return normalizedDifference > 180
        ? normalizedDifference - 360
        : normalizedDifference;
  }

  void calculateQiblaBearing(Location? location) {
    emit(QiblaLoading());

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

    _qiblaBearing = _calculateQiblaBearingUseCase(
      latitude: latitude,
      longitude: longitude,
    );
    _emitSuccessIfReady();
  }

  @override
  Future<void> close() async {
    await _compassSubscription?.cancel();
    return super.close();
  }
}
