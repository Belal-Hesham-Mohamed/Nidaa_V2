import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/generated/l10n.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';

class PrayerTimesList extends StatelessWidget {
  final String activePrayer;
  final Timings? timings;

  const PrayerTimesList({
    super.key,
    required this.activePrayer,
    this.timings,
  });

  List<Map<String, String>> _getPrayerItems(S s) {
    if (timings != null) {
      return [
        {'name': s.prayerFajr, 'time': timings!.fajr},
        {'name': s.prayerSunrise, 'time': timings!.sunrise},
        {'name': s.prayerDhuhr, 'time': timings!.dhuhr},
        {'name': s.prayerAsr, 'time': timings!.asr},
        {'name': s.prayerMaghrib, 'time': timings!.maghrib},
        {'name': s.prayerIsha, 'time': timings!.isha},
      ];
    }
    return [
      {'name': s.prayerFajr, 'time': '04:35 AM'},
      {'name': s.prayerSunrise, 'time': '06:02 AM'},
      {'name': s.prayerDhuhr, 'time': '12:58 PM'},
      {'name': s.prayerAsr, 'time': '04:27 PM'},
      {'name': s.prayerMaghrib, 'time': '07:54 PM'},
      {'name': s.prayerIsha, 'time': '09:21 PM'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    final activeColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentBlue;

    final s = S.of(context);
    final prayersList = _getPrayerItems(s);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: prayersList.map((prayer) {
                final isActive = prayer['name'] == activePrayer;

                return Expanded(
                  child: _PrayerTimeItem(
                    name: prayer['name']!,
                    time: prayer['time']!,
                    isActive: isActive,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    activeColor: activeColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrayerTimeItem extends StatelessWidget {
  final String name;
  final String time;
  final bool isActive;
  final Color primaryText;
  final Color secondaryText;
  final Color activeColor;

  const _PrayerTimeItem({
    required this.name,
    required this.time,
    required this.isActive,
    required this.primaryText,
    required this.secondaryText,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            _getPrayerIcon(name),
            size: 22,
            color: isActive ? activeColor : secondaryText,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : primaryText,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return Icons.nightlight_round;
      case 'Sunrise':
        return Icons.wb_sunny_outlined;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.wb_twilight;
      case 'Maghrib':
        return Icons.nights_stay_outlined;
      case 'Isha':
        return Icons.dark_mode_outlined;
      default:
        return Icons.access_time;
    }
  }
}