import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/generated/l10n.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accentColor = isDark ? AppColors.darkAccentGold : AppColors.lightAccentBlue;
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final displayPrayerTime = prayerTime.trim().split(RegExp(r'\s+')).first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final circleSize = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox(
            width: circleSize,
            height: circleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(circleSize),
                  painter: _PrayerProgressPainter(
                    progress: normalizedProgress,
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSecondaryBackground,
                    progressColor: accentColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(circleSize * 0.18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        prayerName,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: circleSize * 0.095, fontWeight: FontWeight.w700, color: primaryText),
                      ),
                      SizedBox(height: circleSize * 0.045),
                      Text(
                        countdown,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: circleSize * 0.115, fontWeight: FontWeight.w600, color: primaryText, letterSpacing: 0.5),
                      ),
                      SizedBox(height: circleSize * 0.015),
                      Text(
                        S.of(context).remaining,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: circleSize * 0.045, fontWeight: FontWeight.w400, color: secondaryText),
                      ),
                      SizedBox(height: circleSize * 0.045),
                      Text(
                        displayPrayerTime,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: circleSize * 0.065, fontWeight: FontWeight.w600, color: primaryText),
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

class _PrayerProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _PrayerProgressPainter({required this.progress, required this.backgroundColor, required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = backgroundColor;
    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final outerGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..color = progressColor.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawArc(rect, startAngle, sweepAngle, false, outerGlowPaint);

      final innerGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..color = progressColor.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(rect, startAngle, sweepAngle, false, innerGlowPaint);

      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = progressColor;
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

      final endAngle = startAngle + sweepAngle;
      final endpoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final endpointGlowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = progressColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
      canvas.drawCircle(endpoint, 9, endpointGlowPaint);

      final endpointPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = progressColor;
      canvas.drawCircle(endpoint, 5, endpointPaint);

      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawCircle(endpoint, 2, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PrayerProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
