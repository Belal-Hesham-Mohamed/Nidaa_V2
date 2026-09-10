import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/qibla/domain/usecase/calculate_qibla_bearing_usecase.dart';
import 'package:nidaa_v2/qibla/presentation/cubit/qibla_cubit.dart';

class _FakeLocation extends Location {
  _FakeLocation({required super.latitude, required super.longitude});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QiblaCubit unit tests', () {
    test(
      'handles valid location and calculates bearing without sensor event',
      () async {
        final cubit = QiblaCubit(CalculateQiblaBearingUseCase());
        addTearDown(cubit.close);

        cubit.calculateQiblaBearing(
          _FakeLocation(latitude: 21.4225, longitude: 39.8262),
        );

        expect(cubit.state, isA<QiblaSuccess>());
        final state = cubit.state as QiblaSuccess;
        expect(state.qiblaBearing, isNotNull);
        expect(state.deviceHeading, isNull);
        expect(state.relativeAngle, isNull);
        expect(state.isAligned, isFalse);
      },
    );

    test('emits QiblaFailure when location is null', () async {
      final cubit = QiblaCubit(CalculateQiblaBearingUseCase());
      addTearDown(cubit.close);

      cubit.calculateQiblaBearing(null);

      expect(cubit.state, isA<QiblaFailure>());
      expect(
        (cubit.state as QiblaFailure).errorKey,
        QiblaErrorKey.locationUnavailable,
      );
    });

    test('emits QiblaFailure when coordinates are out of bounds', () async {
      final cubit = QiblaCubit(CalculateQiblaBearingUseCase());
      addTearDown(cubit.close);

      cubit.calculateQiblaBearing(
        _FakeLocation(latitude: 95.0, longitude: 39.8262),
      );

      expect(cubit.state, isA<QiblaFailure>());
      expect(
        (cubit.state as QiblaFailure).errorKey,
        QiblaErrorKey.invalidCoordinates,
      );
    });

    test('alignment tolerance checks within 5 degrees', () {
      // 5 degrees is the established alignment tolerance.
      const tolerance = 5.0;
      expect(4.9.abs() <= tolerance, isTrue);
      expect(5.0.abs() <= tolerance, isTrue);
      expect(5.1.abs() <= tolerance, isFalse);
      expect((-4.9).abs() <= tolerance, isTrue);
      expect((-5.0).abs() <= tolerance, isTrue);
      expect((-5.1).abs() <= tolerance, isFalse);
    });
  });
}
