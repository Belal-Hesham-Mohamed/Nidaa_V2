import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/qibla/domain/usecase/calculate_qibla_bearing_usecase.dart';

part 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  final CalculateQiblaBearingUseCase _calculateQiblaBearingUseCase;

  QiblaCubit(this._calculateQiblaBearingUseCase) : super(QiblaInitial());

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

    final qiblaBearing = _calculateQiblaBearingUseCase(
      latitude: latitude,
      longitude: longitude,
    );
    emit(QiblaSuccess(qiblaBearing: qiblaBearing));
  }
}
