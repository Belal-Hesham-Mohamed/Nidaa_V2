import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/core/dependency_injection.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_header.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_hero.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_list.dart';
import 'package:nidaa_v2/settings/presentation/screens/settings_screen.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  int currentIndex = 0;
  late final PrayerTimesCubit _prayerTimesCubit;

  @override
  void initState() {
    super.initState();
    _prayerTimesCubit = sl<PrayerTimesCubit>();
    _prayerTimesCubit.getPrayerTimes();
  }

  @override
  void dispose() {
    _prayerTimesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      extendBody: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/light_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark/Light overlay
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.01),
            ),
          ),

          // Main content
          SafeArea(
            child: _buildCurrentTab(),
          ),
        ],
      ),

      // Floating Bottom Navigation
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            10,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: navigationColor.withValues(
                  alpha: 0.95,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: activeColor.withValues(
                  alpha: 0.12,
                ),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (currentIndex == 0) {
      return _buildPrayerTimesContent();
    }

    if (currentIndex == 3) {
      return SettingsScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        locale: widget.locale,
        onLocaleChanged: widget.onLocaleChanged,
      );
    }

    return _buildPlaceholderContent();
  }

  Widget _buildPrayerTimesContent() {
    return BlocProvider<PrayerTimesCubit>.value(
      value: _prayerTimesCubit,
      child: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
        builder: (context, state) {
          if (state is PrayerTimesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PrayerTimesFailure) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final primaryText = isDark
                ? AppColors.darkPrimaryText
                : AppColors.lightPrimaryText;
            final accentColor = isDark
                ? AppColors.darkAccentGold
                : AppColors.lightAccentBlue;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<PrayerTimesCubit>().getPrayerTimes();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is PrayerTimesSuccess) {
            final prayerTimes = state.prayerTimes;
            final locationName = state.locationName;
            final isFallback = state.isFallbackLocation;

            final activePrayerName = _determineActivePrayer(prayerTimes.timings);

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
                        PrayerTimesHeader(
                          location: isFallback
                              ? '$locationName (Saved)'
                              : locationName,
                          hijriDate: prayerTimes.date.hijri,
                          gregorianDate: prayerTimes.date.gregorian,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 220,
                          child: PrayerTimesHero(
                            prayerName: activePrayerName,
                            prayerTime: _getPrayerTimeByName(
                              prayerTimes.timings,
                              activePrayerName,
                            ),
                            countdown: _calculateCountdown(
                              prayerTimes.timings,
                              activePrayerName,
                            ),
                            progress: 0.65,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: PrayerTimesList(
                            activePrayer: activePrayerName,
                            timings: prayerTimes.timings,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _determineActivePrayer(Timings timings) {
    final now = DateTime.now();
    final times = [
      {'name': 'Fajr', 'time': timings.fajr},
      {'name': 'Sunrise', 'time': timings.sunrise},
      {'name': 'Dhuhr', 'time': timings.dhuhr},
      {'name': 'Asr', 'time': timings.asr},
      {'name': 'Maghrib', 'time': timings.maghrib},
      {'name': 'Isha', 'time': timings.isha},
    ];

    for (final prayer in times) {
      final prayerDateTime = _parseTimeString(now, prayer['time']!);
      if (prayerDateTime != null && prayerDateTime.isAfter(now)) {
        return prayer['name']!;
      }
    }
    return 'Fajr';
  }

  String _getPrayerTimeByName(Timings timings, String name) {
    switch (name) {
      case 'Fajr':
        return timings.fajr;
      case 'Sunrise':
        return timings.sunrise;
      case 'Dhuhr':
        return timings.dhuhr;
      case 'Asr':
        return timings.asr;
      case 'Maghrib':
        return timings.maghrib;
      case 'Isha':
        return timings.isha;
      default:
        return timings.dhuhr;
    }
  }

  String _calculateCountdown(Timings timings, String nextPrayerName) {
    final now = DateTime.now();
    final timeStr = _getPrayerTimeByName(timings, nextPrayerName);
    var target = _parseTimeString(now, timeStr);

    if (target == null) return '00:00:00';
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    final diff = target.difference(now);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  DateTime? _parseTimeString(DateTime baseDate, String timeStr) {
    try {
      final cleanStr = timeStr.split(' ')[0];
      final parts = cleanStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  Widget _buildPlaceholderContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
