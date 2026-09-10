part of 'qibla_cubit.dart';

@immutable
sealed class QiblaState {}

final class QiblaInitial extends QiblaState {}

final class QiblaLoading extends QiblaState {}

final class QiblaSuccess extends QiblaState {
  final double qiblaBearing;

  QiblaSuccess({required this.qiblaBearing});
}

enum QiblaErrorKey { locationUnavailable, invalidCoordinates }

final class QiblaFailure extends QiblaState {
  final QiblaErrorKey errorKey;

  QiblaFailure(this.errorKey);
}
