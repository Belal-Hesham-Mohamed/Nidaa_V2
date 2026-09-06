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

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Next Prayer',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            prayerName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            prayerTime,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: 190,
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 8,
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSecondaryBackground,
                  ),
                ),

                SizedBox(
                  width: 190,
                  height: 190,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    color: accentColor,
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countdown,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'remaining',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}