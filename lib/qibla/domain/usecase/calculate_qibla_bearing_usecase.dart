import 'dart:math';

class CalculateQiblaBearingUseCase {
  double call({
    required double latitude,
    required double longitude,
  }) {
    const kaabaLatitude = 21.4225;
    const kaabaLongitude = 39.8262;

    final userLatitude = _degreesToRadians(latitude);
    final userLongitude = _degreesToRadians(longitude);
    final targetLatitude = _degreesToRadians(kaabaLatitude);
    final targetLongitude = _degreesToRadians(kaabaLongitude);

    final deltaLongitude = targetLongitude - userLongitude;

    final y = sin(deltaLongitude);

    final x =
        cos(userLatitude) * sin(targetLatitude) -
        sin(userLatitude) *
            cos(targetLatitude) *
            cos(deltaLongitude);

    final bearing = atan2(y, x) * 180 / pi;

    return _normalizeBearing(bearing);
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double _normalizeBearing(double bearing) {
    return (bearing + 360) % 360;
  }

  
}
