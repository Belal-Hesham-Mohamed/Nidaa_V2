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
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _refreshTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    final s = S.of(context);
    return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
      bloc: widget.prayerTimesCubit,
      builder: (context, state) {
        final period = state is PrayerTimesSuccess ? _resolver.resolve(fajr: state.prayerTimes.timings.fajr, sunrise: state.prayerTimes.timings.sunrise, asr: state.prayerTimes.timings.asr, maghrib: state.prayerTimes.timings.maghrib) : CurrentAzkarPeriod.none;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('NIDAA', style: TextStyle(color: colors.accent, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(s.azkarHeader, style: TextStyle(color: colors.primary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _CurrentCard(period: period, colors: colors),
            const SizedBox(height: 26),
            Text(s.azkarSectionTitle, style: TextStyle(color: colors.primary, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 360;
              return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: azkarCategories.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: twoColumns ? 2 : 1, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: twoColumns ? 1.52 : 3.5), itemBuilder: (context, index) => _CategoryCard(category: azkarCategories[index], colors: colors, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AzkarCategoryScreen(category: azkarCategories[index])))));
            }),
          ]),
        );
      },
    );
  }

  _AzkarColors _colors(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; return _AzkarColors(dark ? AppColors.darkBackground : AppColors.lightBackground, dark ? AppColors.darkSurface : AppColors.lightSurface, dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText, dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText, dark ? AppColors.darkAccentGold : AppColors.lightAccentBlue); }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.period, required this.colors});
  final CurrentAzkarPeriod period;
  final _AzkarColors colors;
  @override
  Widget build(BuildContext context) { 
    final s = S.of(context); final active = period != CurrentAzkarPeriod.none; final morning = period == CurrentAzkarPeriod.morning; return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: colors.accent.withValues(alpha: .28))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(active ? s.azkarNow : s.azkarNoCurrentTime, style: TextStyle(color: colors.secondary, fontSize: 13)), const SizedBox(height: 14), Row(children: [Icon(morning ? Icons.wb_sunny_outlined : active ? Icons.nightlight_outlined : Icons.schedule_outlined, color: colors.accent, size: 30), const SizedBox(width: 12), Expanded(child: Text(active ? (morning ? s.azkarMorning : s.azkarEvening) : s.azkarNoCurrentTime, style: TextStyle(color: colors.primary, fontSize: 22, fontWeight: FontWeight.bold))),]), if (active) ...[const SizedBox(height: 8), Text(morning ? s.azkarMorningWindow : s.azkarEveningWindow, style: TextStyle(color: colors.secondary))]])) ; }
}

class _CategoryCard extends StatelessWidget { const _CategoryCard({
  required this.category,
   required this.colors, 
   required this.onTap});
    final AzkarCategory category; 
    final _AzkarColors colors;
     final VoidCallback onTap;
      @override 
      Widget build(BuildContext context) {
         final s = S.of(context); 
         return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.primary.withValues(alpha: .07))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(category.icon, color: colors.accent, size: 25), Icon(Icons.arrow_forward_ios, color: colors.secondary, size: 14)]), Text(categoryTitle(s, category.id), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.primary, fontSize: 16, fontWeight: FontWeight.w700)), Text('${category.items.length} ${s.azkarItems}', style: TextStyle(color: colors.secondary, fontSize: 12))])));  } }

class _AzkarColors { const _AzkarColors(this.background, this.surface, this.primary, this.secondary, this.accent); final Color background, surface, primary, secondary, accent; }
