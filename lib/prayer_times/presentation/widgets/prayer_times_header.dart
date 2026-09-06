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

  String _getWeekday(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return weekdays[date.weekday - 1];
  }

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

    final weekday = _getWeekday(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        8,
        14,
        8,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // Location
        Row(
  children: [
    Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: accentColor.withValues(
          alpha: 0.10,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.location_on_outlined,
        size: 18,
        color: accentColor,
      ),
    ),

    const SizedBox(width: 9),

    Expanded(
      child: Text(
        location,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),
    ),

    const SizedBox(width: 6),

    Icon(
      Icons.mosque_outlined,
      size: 21,
      color: accentColor,
    ),
  ],
),   const SizedBox(height: 2),

          // Divider
          Container(
            height: 1,
            color: secondaryText.withValues(
              alpha: 0.10,
            ),
          ),

          const SizedBox(height: 3),

          // Dates
          Row(
            children: [
              // Hijri
              Expanded(
                child: Text(
                  hijriDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Separator
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 8),

              // Weekday
              Text(
                weekday,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),

              const SizedBox(width: 8),

              // Separator
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 8),

              // Gregorian
              Expanded(
                child: Text(
                  gregorianDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: primaryText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}