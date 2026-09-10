import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nidaa_v2/core/dependency_injection.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_saved_current_location_usecase.dart';
import 'package:nidaa_v2/qibla/presentation/cubit/qibla_cubit.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late final QiblaCubit _qiblaCubit;
  final GetLocationUsecase _getLocationUsecase = sl<GetLocationUsecase>();
  final GetSavedCurrentLocationUsecase _getSavedCurrentLocationUsecase =
      sl<GetSavedCurrentLocationUsecase>();

  @override
  void initState() {
    super.initState();
    _qiblaCubit = sl<QiblaCubit>();
    _calculateQibla();
  }

  Future<void> _calculateQibla() async {
    final result = await _getLocationUsecase();
    Location? location;

    result.fold(
      (_) async {
        final savedResult = await _getSavedCurrentLocationUsecase();
        savedResult.fold(
          (_) {},
          (saved) => location = saved,
        );
      },
      (loc) => location = loc,
    );

    if (mounted) {
      _qiblaCubit.calculateQiblaBearing(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QiblaCubit>.value(
      value: _qiblaCubit,
      child: BlocBuilder<QiblaCubit, QiblaState>(
        builder: (context, state) {
          if (state is QiblaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QiblaSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Qibla Bearing\n${state.qiblaBearing.toStringAsFixed(1)}°',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Device Heading\n${state.deviceHeading?.toStringAsFixed(1) ?? '--'}°',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Relative Angle\n${state.relativeAngle?.toStringAsFixed(1) ?? '--'}°',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shortest Angle\n${state.shortestAngle?.toStringAsFixed(1) ?? '--'}°',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.isAligned ? 'Facing Qibla' : 'Not Facing Qibla',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          if (state is QiblaFailure) {
            return Center(
              child: Text('Error: ${state.errorKey}'),
            );
          }

          return const Center(child: Text('Qibla'));
        },
      ),
    );
  }
}
