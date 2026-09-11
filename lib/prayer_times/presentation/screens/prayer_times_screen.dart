import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/core/dependency_injection.dart';
import 'package:nidaa_v2/core/widgets/app_bottom_navigation_bar.dart';
import 'package:nidaa_v2/azkar/presentation/screens/azkar_home_screen.dart';
import 'package:nidaa_v2/generated/l10n.dart';
import 'package:nidaa_v2/location/current_location/domain/entities/location.dart';
import 'package:nidaa_v2/prayer_times/domain/entities/prayer_times.dart';
import 'package:nidaa_v2/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_header.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_hero.dart';
import 'package:nidaa_v2/prayer_times/presentation/widgets/prayer_times_list.dart';
import 'package:nidaa_v2/qibla/presentation/screens/qibla_screen.dart';
import 'package:nidaa_v2/settings/presentation/screens/settings_screen.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key, required this.themeMode, required this.onThemeModeChanged, required this.locale, required this.onLocaleChanged});

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

  void _refreshPrayerTimesAfterLocationChange() => _prayerTimesCubit.getPrayerTimes();

  Future<String> _localizedCurrentLocation(Location location, Locale locale) async {
    if (locale.languageCode == 'en') return _canonicalLocationName(location);
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(location.latitude, location.longitude, locale: Locale(locale.languageCode));
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final parts = <String>[];
        final city = (placemark.locality ?? placemark.subAdministrativeArea ?? '').trim();
        final country = (placemark.country ?? '').trim();
        if (city.isNotEmpty) parts.add(city);
        if (country.isNotEmpty) parts.add(country);
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(child: _buildCurrentTab()),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (currentIndex == 0) return _buildPrayerTimesContent();
    if (currentIndex == 1) return const QiblaScreen();
    if (currentIndex == 2) return AzkarHomeScreen(prayerTimesCubit: _prayerTimesCubit);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/light_background.png', fit: BoxFit.cover),
        Container(
          color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.01),
        ),
        BlocProvider<PrayerTimesCubit>.value(
          value: _prayerTimesCubit,
          child: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
            builder: (context, state) {
              if (state is PrayerTimesLoading) return const Center(child: CircularProgressIndicator());
              if (state is PrayerTimesFailure) {
                final s = S.of(context);
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
                final Widget locationHeader;
                if (state.currentLocation == null) {
                  final locationName = isFallback ? '${state.locationName} ${S.current.savedSuffix}' : state.locationName;
                  locationHeader = PrayerTimesHeader(location: locationName == 'Current Location' ? S.current.currentLocationFallback : locationName, hijriDate: _buildHijriDate(prayerTimes.date), gregorianDate: _buildGregorianDate(prayerTimes.date), currentLocationFallbackLabel: S.current.currentLocationFallback);
                } else {
                  locationHeader = FutureBuilder<String>(
                    key: ValueKey('${state.currentLocation!.latitude}_${state.currentLocation!.longitude}_${widget.locale.languageCode}'),
                    future: _localizedCurrentLocation(state.currentLocation!, widget.locale),
                    builder: (context, snapshot) {
                      final locationName = snapshot.data ?? state.locationName;
                      final displayName = isFallback ? '$locationName ${S.current.savedSuffix}' : locationName;
                      return PrayerTimesHeader(location: displayName, hijriDate: _buildHijriDate(prayerTimes.date), gregorianDate: _buildGregorianDate(prayerTimes.date), currentLocationFallbackLabel: S.current.currentLocationFallback);
                    },
                  );
                }
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            locationHeader,
                            const SizedBox(height: 6),
                            SizedBox(height: 220, child: PrayerTimesHero(prayerName: localizedActivePrayer, prayerTime: _localizeDigits(_getPrayerTimeByName(prayerTimes.timings, activePrayerName)), countdown: _localizeDigits(_calculateCountdown(prayerTimes.timings, activePrayerName)), progress: _calculateProgress(prayerTimes.timings, activePrayerName))),
                            const SizedBox(height: 4),
                            Expanded(child: PrayerTimesList(activePrayer: localizedActivePrayer, timings: _localizedTimings(prayerTimes.timings))),
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
        ),
      ],
    );
  }

  String _determineActivePrayer(Timings timings) {
    final now = DateTime.now();
    final times = [
      {'name': 'Fajr', 'time': timings.fajr}, {'name': 'Sunrise', 'time': timings.sunrise},
      {'name': 'Dhuhr', 'time': timings.dhuhr}, {'name': 'Asr', 'time': timings.asr},
      {'name': 'Maghrib', 'time': timings.maghrib}, {'name': 'Isha', 'time': timings.isha},
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
      default: return timings.dhuhr;
    }
  }

  String _calculateCountdown(Timings timings, String nextPrayerName) {
    final now = DateTime.now();
    final timeStr = _getPrayerTimeByName(timings, nextPrayerName);
    var target = _parseTimeString(now, timeStr);
    if (target == null) return '00:00:00';
    if (target.isBefore(now)) target = target.add(const Duration(days: 1));
    final diff = target.difference(now);
    return '${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double _calculateProgress(Timings timings, String nextPrayerName) {
    final now = DateTime.now();
    final prayers = [
      {'name': 'Fajr', 'time': timings.fajr}, {'name': 'Sunrise', 'time': timings.sunrise},
      {'name': 'Dhuhr', 'time': timings.dhuhr}, {'name': 'Asr', 'time': timings.asr},
      {'name': 'Maghrib', 'time': timings.maghrib}, {'name': 'Isha', 'time': timings.isha},
    ];
    final nextIndex = prayers.indexWhere((p) => p['name'] == nextPrayerName);
    if (nextIndex == -1) return 0;
    var nextTime = _parseTimeString(now, prayers[nextIndex]['time']!);
    if (nextTime == null) return 0;
    DateTime? previousTime;
    if (nextIndex > 0) previousTime = _parseTimeString(now, prayers[nextIndex - 1]['time']!);
    else { previousTime = _parseTimeString(now, prayers.last['time']!); previousTime = previousTime?.subtract(const Duration(days: 1)); }
    if (previousTime == null) return 0;
    if (nextTime.isBefore(previousTime)) nextTime = nextTime.add(const Duration(days: 1));
    if (now.isBefore(previousTime)) previousTime = previousTime.subtract(const Duration(days: 1));
    final totalSeconds = nextTime.difference(previousTime).inSeconds;
    final elapsedSeconds = now.difference(previousTime).inSeconds;
    if (totalSeconds <= 0) return 0;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  DateTime? _parseTimeString(DateTime baseDate, String timeStr) {
    try {
      final cleanStr = timeStr.trim().split(' ')[0];
      final parts = cleanStr.split(':');
      return DateTime(baseDate.year, baseDate.month, baseDate.day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) { return null; }
  }

  Widget _buildPlaceholderContent() {
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    return Center(child: Text(s.comingSoon, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primaryText)));
  }

  String _buildHijriDate(Date date) {
    final isAr = widget.locale.languageCode == 'ar';
    final month = isAr ? date.hijriMonthAr : date.hijriMonthEn;
    final day = isAr ? _toArabicIndic(date.hijriDay) : date.hijriDay;
    final year = isAr ? _toArabicIndic(date.hijriYear) : date.hijriYear;
    return '$day $month $year';
  }

  String _buildGregorianDate(Date date) {
    final value = date.gregorian;
    return widget.locale.languageCode == 'ar' ? _toArabicIndic(value) : value;
  }

  String _localizeDigits(String value) => widget.locale.languageCode == 'ar' ? _toArabicIndic(value) : value;

  Timings _localizedTimings(Timings timings) {
    if (widget.locale.languageCode != 'ar') return timings;
    return Timings(fajr: _toArabicIndic(timings.fajr), sunrise: _toArabicIndic(timings.sunrise), dhuhr: _toArabicIndic(timings.dhuhr), asr: _toArabicIndic(timings.asr), maghrib: _toArabicIndic(timings.maghrib), isha: _toArabicIndic(timings.isha));
  }

  String _toArabicIndic(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (int i = 0; i < english.length; i++) result = result.replaceAll(english[i], arabic[i]);
    return result;
  }
}
