import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';

class PrayerTimesHero extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final String countdown;
  final double progress;

  const PrayerTimesHero({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.countdown,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final accentColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentBlue;

    final normalizedProgress =
        progress.clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size.square(320),
              painter: _PrayerProgressPainter(
                progress: normalizedProgress,
                backgroundColor: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSecondaryBackground,
                progressColor: accentColor,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(72),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    prayerName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    countdown,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'remaining',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: secondaryText,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    prayerTime,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _PrayerProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 14;

    const startAngle = -math.pi / 2;

    final sweepAngle =
        2 * math.pi * progress;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    // Background ring
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = backgroundColor;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    if (progress > 0) {
      // Outer soft glow
      final outerGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..color = progressColor.withValues(
          alpha: 0.10,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          14,
        );

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        outerGlowPaint,
      );

      // Stronger inner glow
      final innerGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = progressColor.withValues(
          alpha: 0.22,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          7,
        );

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        innerGlowPaint,
      );

      // Main progress ring
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = progressColor;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      // Endpoint position
      final endAngle =
          startAngle + sweepAngle;

      final endpoint = Offset(
        center.dx +
            radius * math.cos(endAngle),
        center.dy +
            radius * math.sin(endAngle),
      );

      // Endpoint glow
      final endpointGlowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = progressColor.withValues(
          alpha: 0.35,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          10,
        );

      canvas.drawCircle(
        endpoint,
        10,
        endpointGlowPaint,
      );

      // Endpoint
      final endpointPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = progressColor;

      canvas.drawCircle(
        endpoint,
        6,
        endpointPaint,
      );

      // Small white highlight
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(
          alpha: 0.85,
        );

      canvas.drawCircle(
        endpoint,
        2,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _PrayerProgressPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor !=
            backgroundColor ||
        oldDelegate.progressColor !=
            progressColor;
  }
}