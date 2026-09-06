import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';

class PrayerTimesHeader extends StatelessWidget {
  final String location;
  final String hijriDate;
  final String gregorianDate;

  const PrayerTimesHeader({
    super.key,
    required this.location,
    required this.hijriDate,
    required this.gregorianDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final accentColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentBlue;

    return Row(
      children: [
        // Location
        Expanded(
          flex: 5,
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 19,
                    color: accentColor,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: secondaryText,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Date
        Expanded(
          flex: 5,
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hijriDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  gregorianDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}