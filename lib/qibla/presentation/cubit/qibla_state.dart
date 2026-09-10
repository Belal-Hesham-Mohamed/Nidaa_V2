part of 'qibla_cubit.dart';

@immutable
sealed class QiblaState {}

final class QiblaInitial extends QiblaState {}

final class QiblaLoading extends QiblaState {}

final class QiblaSuccess extends QiblaState {
  final double qiblaBearing;
  final double? deviceHeading;

  QiblaSuccess({
    required this.qiblaBearing,
    this.deviceHeading,
  });
}

enum QiblaErrorKey {
  locationUnavailable,
  invalidCoordinates,
  compassUnavailable,
  compassError,
  headingUnavailable,
}

final class QiblaFailure extends QiblaState {
  final QiblaErrorKey errorKey;

  QiblaFailure(this.errorKey);
}
