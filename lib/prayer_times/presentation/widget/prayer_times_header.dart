import 'package:flutter/material.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              hijriDate,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              gregorianDate,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}