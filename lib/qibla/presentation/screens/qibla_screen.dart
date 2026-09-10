import 'dart:math' as math;

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
  double? _visualAngle;
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
    final location = await result.fold<Future<Location?>>((_) async {
      final savedResult = await _getSavedCurrentLocationUsecase();
      return savedResult.fold<Location?>((_) => null, (saved) => saved);
    }, (loc) async => loc);

    if (mounted) {
      _qiblaCubit.calculateQiblaBearing(location);
    }
  }

  void _updateVisualAngle(double targetDegrees) {
    final targetRadians = targetDegrees * math.pi / 180;
    if (_visualAngle == null) {
      setState(() => _visualAngle = targetRadians);
      return;
    }

    final currentDegrees = _visualAngle! * 180 / math.pi;
    var difference = (targetDegrees - currentDegrees) % 360;
    if (difference > 180) difference -= 360;
    if (difference < -180) difference += 360;

    setState(() => _visualAngle = _visualAngle! + difference * math.pi / 180);
  }

  @override
  void dispose() {
    _qiblaCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QiblaCubit>.value(
      value: _qiblaCubit,
      child: BlocConsumer<QiblaCubit, QiblaState>(
        listener: (context, state) {
          if (state is QiblaSuccess && state.relativeAngle != null) {
            _updateVisualAngle(state.relativeAngle!);
          }
        },
        builder: (context, state) {
          if (state is QiblaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QiblaSuccess) {
            final isAligned = state.isAligned;
            final indicatorColor = isAligned ? Colors.green : Colors.teal;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAligned ? 'Facing Qibla' : 'Find the Qibla',
                      style: TextStyle(
                        color: indicatorColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              border: Border.all(
                                color: indicatorColor,
                                width: 3,
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 12,
                            child: Text(
                              'N',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (_visualAngle != null)
                            AnimatedRotation(
                              turns: _visualAngle! / (2 * math.pi),
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              child: Icon(
                                Icons.navigation,
                                size: 96,
                                color: indicatorColor,
                              ),
                            )
                          else
                            const CircularProgressIndicator(),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: indicatorColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.relativeAngle == null
                          ? 'Waiting for compass heading…'
                          : 'Turn the phone until the arrow points up',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Qibla ${state.qiblaBearing.toStringAsFixed(1)}°  •  '
                      'Heading ${state.deviceHeading?.toStringAsFixed(1) ?? '--'}°',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is QiblaFailure) {
            return Center(child: Text('Error: ${state.errorKey}'));
          }

          return const Center(child: Text('Qibla'));
        },
      ),
    );
  }
}
