import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/core/dependency_injection.dart';
import 'package:nidaa_v2/generated/l10n.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _prayerTimesCubit = sl<PrayerTimesCubit>();
    _prayerTimesCubit.getPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && currentIndex == 0) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _prayerTimesCubit.close();
    super.dispose();
  }

  void _refreshPrayerTimesAfterLocationChange() {
    _prayerTimesCubit.getPrayerTimes();
  }

  Future<String> _localizedCurrentLocation(Location location, Locale locale) async {
    if (locale.languageCode == 'en') {
      return _canonicalLocationName(location);
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
        localeIdentifier: locale.languageCode,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final parts = <String>[];
        final city = (placemark.locality ?? placemark.subAdministrativeArea ?? '').trim();
        final country = (placemark.country ?? '').trim();
        if (city.isNotEmpty) parts.add(city);
        if (country.isNotEmpty) parts.add(country);
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // Keep the canonical English value as a safe fallback.
    }

    return _canonicalLocationName(location);
  }

  String _canonicalLocationName(Location location) {
    final parts = <String>[];
    if (location.city != null && location.city!.isNotEmpty) parts.add(location.city!);
    if (location.country != null && location.country!.isNotEmpty) parts.add(location.country!);
    return parts.isNotEmpty ? parts.join(', ') : 'Current Location';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final navigationColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final inactiveColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final activeColor = isDark ? AppColors.darkAccentGold : AppColors.lightAccentBlue;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/light_background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.01))),
          SafeArea(child: _buildCurrentTab()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(color: navigationColor.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(16)),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) => setState(() => currentIndex = index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: activeColor.withValues(alpha: 0.12),
                destinations: [
                  NavigationDestination(icon: Icon(Icons.access_time, color: inactiveColor), selectedIcon: Icon(Icons.access_time, color: activeColor), label: s.navPrayerTimes),
                  NavigationDestination(icon: Icon(Icons.explore_outlined, color: inactiveColor), selectedIcon: Icon(Icons.explore, color: activeColor), label: s.navQibla),
                  NavigationDestination(icon: Icon(Icons.menu_book_outlined, color: inactiveColor), selectedIcon: Icon(Icons.menu_book, color: activeColor), label: s.navAzkar),
                  NavigationDestination(icon: Icon(Icons.settings_outlined, color: inactiveColor), selectedIcon: Icon(Icons.settings, color: activeColor), label: s.navSettings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (currentIndex == 0) return _buildPrayerTimesContent();
    if (currentIndex == 3) {
      return SettingsScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        locale: widget.locale,
        onLocaleChanged: widget.onLocaleChanged,
        onLocationChanged: _refreshPrayerTimesAfterLocationChange,
      );
    }
    return _buildPlaceholderContent();
  }

  Widget _buildPrayerTimesContent() {
    return BlocProvider<PrayerTimesCubit>.value(
      value: _prayerTimesCubit,
      child: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
        builder: (context, state) {
          if (state is PrayerTimesLoading) return const Center(child: CircularProgressIndicator());

          if (state is PrayerTimesFailure) {
            final s = S.of(context);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final primaryText = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
            final accentColor = isDark ? AppColors.darkAccentGold : AppColors.lightAccentBlue;
            String localizedMessage;
            switch (state.errorKey) {
              case PrayerTimesErrorKey.noSavedManualLocation: localizedMessage = s.errorNoSavedManualLocation; break;
              case PrayerTimesErrorKey.manualLocationIncomplete: localizedMessage = s.errorManualLocationIncomplete; break;
              case PrayerTimesErrorKey.currentLocationUnavailable: localizedMessage = s.errorCurrentLocationUnavailable; break;
              case PrayerTimesErrorKey.noPrayerTimes: localizedMessage = s.errorNoPrayerTimes; break;
              case PrayerTimesErrorKey.unknown: localizedMessage = state.rawMessage ?? s.errorNoPrayerTimes; break;
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(localizedMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: primaryText)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<PrayerTimesCubit>().getPrayerTimes(),
                      icon: const Icon(Icons.refresh),
                      label: Text(s.retry),
                      style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PrayerTimesSuccess) {
            final prayerTimes = state.prayerTimes;
            final isFallback = state.isFallbackLocation;
            final activePrayerName = _determineActivePrayer(prayerTimes.timings);
            final s = S.of(context);
            final localizedActivePrayer = _localizePrayerName(activePrayerName, s);

            final locationWidget = state.currentLocation == null
                ? PrayerTimesHeader(
                    location: isFallback ? '${state.locationName} ${S.current.savedSuffix}' : state.locationName,
                    hijriDate: _buildHijriDate(prayerTimes.date),
                    gregorianDate: _buildGregorianDate(prayerTimes.date),
                    currentLocationFallbackLabel: S.current.currentLocationFallback,
                  )
                : FutureBuilder<String>(
                    key: ValueKey('${state.currentLocation!.latitude}_${state.currentLocation!.longitude}_${widget.locale.languageCode}'),
                    future: _localizedCurrentLocation(state.currentLocation!, widget.locale),
                    builder: (context, snapshot) {
                      final locationName = snapshot.data ?? state.locationName;
                      final displayName = isFallback ? '$locationName ${S.current.savedSuffix}' : locationName;
                      return PrayerTimesHeader(
                        location: displayName,
                        hijriDate: _buildHijriDate(prayerTimes.date),
                        gregorianDate: _buildGregorianDate(prayerTimes.date),
                        currentLocationFallbackLabel: S.current.currentLocationFallback,
                      );
                    },
                  );

            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        locationWidget,
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 220,
                          child: PrayerTimesHero(
                            prayerName: localizedActivePrayer,
                            prayerTime: _localizeDigits(_getPrayerTimeByName(prayerTimes.timings, activePrayerName)),
                            countdown: _localizeDigits(_calculateCountdown(prayerTimes.timings, activePrayerName)),
                            progress: _calculateProgress(prayerTimes.timings, activePrayerName),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: PrayerTimesList(
                            activePrayer: localizedActivePrayer,
                            timings: _localizedTimings(prayerTimes.timings),
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
      if (prayerDateTime != null && prayerDateTime.isAfter(now)) return prayer['name']!;
    }
    return 'Fajr';
  }

  String _localizePrayerName(String name, S s) {
    switch (name) {
      case 'Fajr': return s.prayerFajr;
      case 'Sunrise': return s.prayerSunrise;
      case 'Dhuhr': return s.prayerDhuhr;
      case 'Asr': return s.prayerAsr;
      case 'Maghrib': return s.prayerMaghrib;
      case 'Isha': return s.prayerIsha;
      default: return s.prayerFajr;
    }
  }

  String _getPrayerTimeByName(Timings timings, String name) {
    switch (name) {
      case 'Fajr': return timings.fajr;
      case 'Sunrise': return timings.sunrise;
      case 'Dhuhr': return timings.dhuhr;
      case 'Asr': return timings.asr;
      case 'Maghrib': return timings.maghrib;
      case 'Isha': return timings.isha;
      default: return timings.fajr;
    }
  }

  DateTime? _parseTimeString(DateTime now, String time) {
    final cleanTime = time.split(' ').first;
    final parts = cleanTime.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String _buildHijriDate(dynamic date) => date.hijri;
  String _buildGregorianDate(dynamic date) => date.gregorian;
  String _localizeDigits(String value) => widget.locale.languageCode == 'ar'
      ? value.replaceAllMapped(RegExp(r'[0-9]'), (m) => '٠١٢٣٤٥٦٧٨٩'[int.parse(m.group(0)!)]).replaceAll(':', ' : ')
      : value;

  Map<String, String> _localizedTimings(Timings timings) => {
    'Fajr': _localizeDigits(timings.fajr),
    'Sunrise': _localizeDigits(timings.sunrise),
    'Dhuhr': _localizeDigits(timings.dhuhr),
    'Asr': _localizeDigits(timings.asr),
    'Maghrib': _localizeDigits(timings.maghrib),
    'Isha': _localizeDigits(timings.isha),
  };

  double _calculateProgress(Timings timings, String activePrayer) => 0.0;
  String _calculateCountdown(Timings timings, String activePrayer) => '--:--';

  Widget _buildPlaceholderContent() => const Center(child: Text('Coming Soon'));
}