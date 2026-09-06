import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_header.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_hero.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_list.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() =>
      _PrayerTimesScreenState();
}

class _PrayerTimesScreenState
    extends State<PrayerTimesScreen> {
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

    return  Scaffold(
  backgroundColor: backgroundColor,

  body: Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/light_background.png',
          fit: BoxFit.cover,
        ),
      ),

      Positioned.fill(
        child: Container(
          color: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.01),
        ),
      ),

      SafeArea(
        child: currentIndex == 0
            ? _buildPrayerTimesContent()
            : _buildPlaceholderContent(),
      ),
    ],
  ),
      bottomNavigationBar:
       NavigationBar(
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
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              12,
            ),
          child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const PrayerTimesHeader(
      location: 'Cairo, Egypt',
      hijriDate: '10 Ramadan 1447',
      gregorianDate: '28 February 2026',
    ),

    const SizedBox(height: 6),

    SizedBox(
      height: 220,
      child: const PrayerTimesHero(
        prayerName: 'Dhuhr',
        prayerTime: '12:58 PM',
        countdown: '02:34:18',
        progress: 0.65,
      ),
    ),

    const SizedBox(height: 4),

    const Expanded(
      child: PrayerTimesList(
        activePrayer: 'Dhuhr',
      ),
    ),
  ],
),),
        ),

        // Future content goes here.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              children: [
                // Add future sections here.
              ],
            ),
          ),
        ),
      ],
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