import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/core/dependency_injection.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_location_usecase.dart';
import 'package:nidaa_v2/location/current_location/domain/usecase/get_saved_current_location_usecase.dart';
import 'package:nidaa_v2/qibla/domain/qibla_angle.dart';
import 'package:nidaa_v2/qibla/presentation/cubit/qibla_cubit.dart';
import 'package:nidaa_v2/qibla/presentation/localization/qibla_strings.dart';

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
    _initializeQibla();
  }

  Future<void> _initializeQibla() async {
    // The Cubit is a lazy singleton. If Qibla was already initialized during
    // this app session, keep the cached bearing and compass stream alive.
    if (_qiblaCubit.isInitialized) return;

    final result = await _getLocationUsecase();
    final location = await result.fold<Future<Location?>>(
      (_) async {
        final savedResult = await _getSavedCurrentLocationUsecase();
        return savedResult.fold<Location?>(
          (_) => null,
          (saved) => saved,
        );
      },
      (loc) async => loc,
    );

    if (!mounted) return;
    _qiblaCubit.calculateQiblaBearing(location);
  }

  void _updateVisualAngle(double targetDegrees) {
    if (!mounted || !targetDegrees.isFinite) return;

    final targetRadians = targetDegrees * math.pi / 180;
    if (_visualAngle == null) {
      setState(() => _visualAngle = targetRadians);
      return;
    }

    final currentDegrees = _visualAngle! * 180 / math.pi;
    final difference = QiblaAngle.shortestDifference(
      targetDegrees,
      currentDegrees,
    );

    setState(() {
      _visualAngle = _visualAngle! + difference * math.pi / 180;
    });
  }

  @override
  void dispose() {
    // QiblaCubit is a lazy singleton and owns the compass subscription for
    // the app session. It must not be closed when this screen is removed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.qiblaBackgroundTop,
            AppColors.qiblaBackgroundMiddle,
            AppColors.qiblaBackgroundBottom,
          ],
          stops: [0.0, 0.48, 1.0],
        ),
      ),
      child: BlocProvider<QiblaCubit>.value(
        value: _qiblaCubit,
        child: BlocConsumer<QiblaCubit, QiblaState>(
          listener: (context, state) {
            if (state is QiblaSuccess && state.relativeAngle != null) {
              _updateVisualAngle(state.relativeAngle!);
            }
          },
          builder: (context, state) {
            if (state is QiblaSuccess) {
              return _QiblaContent(
                state: state,
                visualAngle: _visualAngle,
              );
            }
            if (state is QiblaFailure) {
              return _QiblaError(errorKey: state.errorKey);
            }
            return const _QiblaWaiting();
          },
        ),
      ),
    );
  }
}

class _QiblaContent extends StatelessWidget {
  const _QiblaContent({required this.state, required this.visualAngle});

  final QiblaSuccess state;
  final double? visualAngle;

  @override
  Widget build(BuildContext context) {
    final strings = QiblaStrings.of(context);
    final isAligned = state.isAligned;
    final accentColor = isAligned
        ? AppColors.qiblaCompassRingAligned
        : AppColors.qiblaCompassRing;
    final arrowColor = isAligned
        ? AppColors.qiblaCompassRingAligned
        : AppColors.qiblaAccentGold;

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 24.0;
        final availableWidth = constraints.maxWidth - horizontalPadding * 2;
        final compassSize = math.min(availableWidth, 390.0);
        final compact = constraints.maxHeight < 680;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              compact ? 12 : 20,
              horizontalPadding,
              12,
            ),
            child: Column(
              children: [
                Text(
                  strings.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkPrimaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkSecondaryText,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: compact ? 12 : 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Compass(
                        size: compassSize,
                        accentColor: accentColor,
                        arrowColor: arrowColor,
                        visualAngle: visualAngle,
                        isAligned: isAligned,
                      ),
                      SizedBox(height: compact ? 14 : 20),
                      _DirectionCard(state: state),
                      const SizedBox(height: 10),
                      _AlignmentIndicator(
                        isAligned: isAligned,
                        accentColor: accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Compass extends StatelessWidget {
  const _Compass({
    required this.size,
    required this.accentColor,
    required this.arrowColor,
    required this.visualAngle,
    required this.isAligned,
  });

  final double size;
  final Color accentColor;
  final Color arrowColor;
  final double? visualAngle;
  final bool isAligned;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: QiblaStrings.of(context).title,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.qiblaCompassSurface,
                border: Border.all(color: accentColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(
                      alpha: isAligned ? 0.32 : 0.12,
                    ),
                    blurRadius: isAligned ? 30 : 16,
                    spreadRadius: isAligned ? 5 : 1,
                  ),
                ],
              ),
            ),
            const _CompassTicks(),
            const Positioned(top: 18, child: _CardinalLabel('N')),
            const Positioned(right: 18, child: _CardinalLabel('E')),
            const Positioned(bottom: 18, child: _CardinalLabel('S')),
            const Positioned(left: 18, child: _CardinalLabel('W')),
            if (visualAngle != null)
              AnimatedRotation(
                turns: visualAngle! / (2 * math.pi),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: _QiblaArrow(color: arrowColor),
              )
            else
              const CircularProgressIndicator(
                color: AppColors.qiblaAccentGold,
              ),
            Container(
              width: size * 0.055,
              height: size * 0.055,
              decoration: BoxDecoration(
                color: AppColors.qiblaCompassSurface,
                shape: BoxShape.circle,
                border: Border.all(color: arrowColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: arrowColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            Positioned(
              top: -2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.qiblaCompassSurface,
                  border: Border.all(
                    color: isAligned
                        ? AppColors.qiblaCompassRingAligned
                        : AppColors.qiblaAccentGold,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isAligned
                              ? AppColors.qiblaCompassRingAligned
                              : AppColors.qiblaAccentGold)
                          .withValues(alpha: isAligned ? 0.45 : 0.18),
                      blurRadius: isAligned ? 18 : 8,
                    ),
                  ],
                ),
                child: const _KaabaMark(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassTicks extends StatelessWidget {
  const _CompassTicks();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _CompassTicksPainter(),
      ),
    );
  }
}

class _CompassTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 14;
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var i = 0; i < 72; i++) {
      final angle = (i * 5 - 90) * math.pi / 180;
      final major = i % 6 == 0;
      final innerRadius = radius - (major ? 15 : 8);

      paint
        ..color = major
            ? AppColors.darkSecondaryText
            : AppColors.darkSecondaryText.withValues(alpha: 0.3)
        ..strokeWidth = major ? 2.2 : 1.1;

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerRadius,
          center.dy + math.sin(angle) * innerRadius,
        ),
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QiblaArrow extends StatelessWidget {
  const _QiblaArrow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.navigation,
      size: 112,
      color: color,
      shadows: [
        Shadow(color: color.withValues(alpha: 0.28), blurRadius: 18),
      ],
    );
  }
}

class _CardinalLabel extends StatelessWidget {
  const _CardinalLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.darkPrimaryText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _KaabaMark extends StatelessWidget {
  const _KaabaMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppColors.qiblaAccentGold, width: 1.5),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 5,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              color: AppColors.qiblaAccentGold,
            ),
          ),
        ),
      ),
    );
  }
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({required this.state});

  final QiblaSuccess state;

  @override
  Widget build(BuildContext context) {
    final strings = QiblaStrings.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.darkAccentTeal.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          _DirectionRow(
            icon: const _KaabaMark(),
            label: strings.qiblaDirection,
            value: '${state.qiblaBearing.toStringAsFixed(1)}°',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: AppColors.darkSecondaryText.withValues(alpha: 0.12),
            ),
          ),
          _DirectionRow(
            icon: const Icon(
              Icons.explore_outlined,
              color: AppColors.qiblaAccentGold,
              size: 28,
            ),
            label: strings.yourHeading,
            value: '${state.deviceHeading?.toStringAsFixed(1) ?? '--'}°',
          ),
        ],
      ),
    );
  }
}

class _DirectionRow extends StatelessWidget {
  const _DirectionRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 34, child: Center(child: icon)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.darkSecondaryText,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.darkPrimaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AlignmentIndicator extends StatelessWidget {
  const _AlignmentIndicator({
    required this.isAligned,
    required this.accentColor,
  });

  final bool isAligned;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = QiblaStrings.of(context);
    final color = isAligned
        ? AppColors.qiblaCompassRingAligned
        : accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isAligned ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: isAligned ? 0.5 : 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                if (isAligned)
                  BoxShadow(
                    color: color.withValues(alpha: 0.7),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isAligned ? strings.aligned : strings.turnToAlign,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaWaiting extends StatelessWidget {
  const _QiblaWaiting();

  @override
  Widget build(BuildContext context) {
    final strings = QiblaStrings.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.qiblaAccentGold),
          const SizedBox(height: 16),
          Text(
            strings.waiting,
            style: const TextStyle(color: AppColors.darkSecondaryText),
          ),
        ],
      ),
    );
  }
}

class _QiblaError extends StatelessWidget {
  const _QiblaError({required this.errorKey});

  final QiblaErrorKey errorKey;

  @override
  Widget build(BuildContext context) {
    final strings = QiblaStrings.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.explore_off_outlined,
              size: 48,
              color: AppColors.darkSecondaryText,
            ),
            const SizedBox(height: 14),
            Text(
              strings.unableToDetermine,
              style: const TextStyle(
                color: AppColors.darkPrimaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _messageFor(strings),
              style: const TextStyle(
                color: AppColors.darkSecondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _messageFor(QiblaStrings strings) {
    switch (errorKey) {
      case QiblaErrorKey.locationUnavailable:
        return strings.locationUnavailable;
      case QiblaErrorKey.invalidCoordinates:
        return strings.invalidCoordinates;
      case QiblaErrorKey.compassUnavailable:
        return strings.compassUnavailable;
      case QiblaErrorKey.compassError:
        return strings.compassError;
      case QiblaErrorKey.headingUnavailable:
        return strings.headingUnavailable;
    }
  }
}
