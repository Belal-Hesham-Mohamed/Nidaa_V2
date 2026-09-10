import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/qibla/domain/qibla_angle.dart';
import 'package:nidaa_v2/qibla/domain/usecase/calculate_qibla_bearing_usecase.dart';

void main() {
  group('QiblaAngle', () {
    test('normalizes values to [0, 360)', () {
      expect(QiblaAngle.normalize(-1), 359);
      expect(QiblaAngle.normalize(360), 0);
      expect(QiblaAngle.normalize(721), 1);
    });

    test('calculates shortest signed circular difference', () {
      expect(QiblaAngle.shortestDifference(1, 359), 2);
      expect(QiblaAngle.shortestDifference(359, 1), -2);
      expect(QiblaAngle.shortestDifference(180, 0), 180);
    });
  });

  test('calculates the great-circle initial bearing to the Kaaba', () {
    final useCase = CalculateQiblaBearingUseCase();

    // London (51.5074 N, 0.1278 W) -> Kaaba is approximately 118.98°.
    expect(
      useCase(latitude: 51.5074, longitude: -0.1278),
      closeTo(118.98, 0.1),
    );
    // Directly south of Kaaba should be almost directly North (0°).
    expect(useCase(latitude: 10.0, longitude: 39.8262), closeTo(0.0, 0.01));
    // Directly north of Kaaba should be almost directly South (180°).
    expect(useCase(latitude: 30.0, longitude: 39.8262), closeTo(180.0, 0.01));
    // Directly west along same latitude roughly points East (~89.8° initial bearing due to spherical geometry).
    expect(useCase(latitude: 21.4225, longitude: 38.8262), closeTo(89.82, 0.1));
  });
}
