import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_header.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_hero.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_list.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final navigationColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final inactiveColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final activeColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentBlue;

    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: currentIndex == 0
            ? _buildPrayerTimesContent()
            : _buildPlaceholderContent(),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: navigationColor,
        indicatorColor:
            activeColor.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.access_time,
              color: inactiveColor,
            ),
            selectedIcon: Icon(
              Icons.access_time,
              color: activeColor,
            ),
            label: 'Prayer Times',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.explore_outlined,
              color: inactiveColor,
            ),
            selectedIcon: Icon(
              Icons.explore,
              color: activeColor,
            ),
            label: 'Qibla',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.menu_book_outlined,
              color: inactiveColor,
            ),
            selectedIcon: Icon(
              Icons.menu_book,
              color: activeColor,
            ),
            label: 'Azkar',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color: inactiveColor,
            ),
            selectedIcon: Icon(
              Icons.settings,
              color: activeColor,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heroHeight =
            (constraints.maxHeight * 0.26)
                .clamp(180.0, 220.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const PrayerTimesHeader(
                location: 'Cairo, Egypt',
                hijriDate: '10 Ramadan 1447',
                gregorianDate: '28 February 2026',
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: heroHeight,
                child: const PrayerTimesHero(
                  prayerName: 'Dhuhr',
                  prayerTime: '12:58 PM',
                  countdown: '02:34:18',
                  progress: 0.65,
                ),
              ),

              const SizedBox(height: 8),

              const PrayerTimesList(
                activePrayer: 'Dhuhr',
              ),

              const SizedBox(height: 24),

              // Future content goes here.
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderContent() {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    return Center(
      child: Text(
        'Coming Soon',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),
    );
  }
}