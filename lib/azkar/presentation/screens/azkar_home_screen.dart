import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nidaa_v2/azkar/data/azkar_data.dart';
import 'package:nidaa_v2/azkar/domain/entities/azkar_entities.dart';
import 'package:nidaa_v2/azkar/domain/services/azkar_time_resolver.dart';
import 'package:nidaa_v2/azkar/presentation/screens/azkar_category_screen.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/generated/l10n.dart';
import 'package:nidaa_v2/prayer_times/presentation/cubit/prayer_times_cubit.dart';

class AzkarHomeScreen extends StatefulWidget {
  const AzkarHomeScreen({super.key, required this.prayerTimesCubit});

  final PrayerTimesCubit prayerTimesCubit;

  @override
  State<AzkarHomeScreen> createState() => _AzkarHomeScreenState();
}

class _AzkarHomeScreenState extends State<AzkarHomeScreen> {
  Timer? _refreshTimer;
  final _resolver = const AzkarTimeResolver();

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    final s = S.of(context);

    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      bloc: widget.prayerTimesCubit,
      builder: (context, state) {
        final resolvedPeriod = state is PrayerTimesSuccess
            ? _resolver.resolve(
                fajr: state.prayerTimes.timings.fajr,
                sunrise: state.prayerTimes.timings.sunrise,
                asr: state.prayerTimes.timings.asr,
                maghrib: state.prayerTimes.timings.maghrib,
              )
            : CurrentAzkarPeriod.none;
        final period = resolvedPeriod == CurrentAzkarPeriod.none
            ? _fallbackPeriod()
            : resolvedPeriod;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _backgroundGradient(context),
              stops: const [0.0, 0.48, 1.0],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AzkarHeader(colors: colors, title: s.azkarHeader),
                const SizedBox(height: 16),
                _CurrentCard(
                  period: period,
                  colors: colors,
                  onTap: () => _openCategory(
                    context,
                    period == CurrentAzkarPeriod.morning
                        ? AzkarCategoryId.morning
                        : AzkarCategoryId.evening,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: s.azkarSectionTitle, colors: colors),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final twoColumns = constraints.maxWidth >= 340;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: azkarCategories.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: twoColumns ? 2 : 1,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: twoColumns ? 138 : 108,
                      ),
                      itemBuilder: (context, index) {
                        final category = azkarCategories[index];
                        return _CategoryCard(
                          category: category,
                          colors: colors,
                          onTap: () => _openCategory(context, category.id),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _backgroundGradient(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? const [
            AppColors.qiblaBackgroundTop,
            AppColors.qiblaBackgroundMiddle,
            AppColors.qiblaBackgroundBottom,
          ]
        : const [
            AppColors.qiblaLightBackgroundTop,
            AppColors.qiblaLightBackgroundMiddle,
            AppColors.qiblaLightBackgroundBottom,
          ];
  }

  CurrentAzkarPeriod _fallbackPeriod() {
    final hour = DateTime.now().hour;
    return hour >= 4 && hour < 16
        ? CurrentAzkarPeriod.morning
        : CurrentAzkarPeriod.evening;
  }

  void _openCategory(BuildContext context, AzkarCategoryId id) {
    final category = azkarCategories.firstWhere((item) => item.id == id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AzkarCategoryScreen(category: category),
      ),
    );
  }

  _AzkarColors _colors(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _AzkarColors(
      dark ? AppColors.darkBackground : AppColors.lightBackground,
      dark ? AppColors.darkSurface : AppColors.lightSurface,
      dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
      dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
      dark ? AppColors.darkAccentGold : AppColors.lightAccentBlue,
    );
  }
}

class _AzkarHeader extends StatelessWidget {
  const _AzkarHeader({required this.colors, required this.title});

  final _AzkarColors colors;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: colors.accent.withValues(alpha: 0.24)),
          ),
          child: Icon(
            Icons.auto_awesome_outlined,
            color: colors.accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NIDAA',
                style: TextStyle(
                  color: colors.accent,
                  fontSize: 10,
                  letterSpacing: 2.6,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.colors});

  final String title;
  final _AzkarColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colors.accent.withValues(alpha: 0.18),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: TextStyle(
              color: colors.primary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colors.accent.withValues(alpha: 0.18),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    required this.period,
    required this.colors,
    required this.onTap,
  });

  final CurrentAzkarPeriod period;
  final _AzkarColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final morning = period == CurrentAzkarPeriod.morning;

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.accent.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.azkarNow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  morning ? s.azkarMorning : s.azkarEvening,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            morning ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
            color: colors.accent,
            size: 38,
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_left, color: colors.secondary, size: 22),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: card,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.colors,
    required this.onTap,
  });

  final AzkarCategory category;
  final _AzkarColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.secondary.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(category.icon, color: colors.accent, size: 27),
                  const Spacer(),
                  Icon(
                    Icons.chevron_left,
                    color: colors.secondary,
                    size: 19,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                categoryTitle(s, category.id),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${category.items.length} ${s.azkarItems}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AzkarColors {
  const _AzkarColors(
    this.background,
    this.surface,
    this.primary,
    this.secondary,
    this.accent,
  );

  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
}
