import 'package:flutter/material.dart';
import 'package:nidaa_v2/azkar/domain/entities/azkar_entities.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/generated/l10n.dart';

class AzkarCategoryScreen extends StatefulWidget {
  const AzkarCategoryScreen({super.key, required this.category});
  final AzkarCategory category;
  @override
  State<AzkarCategoryScreen> createState() => _AzkarCategoryScreenState();
}

class _AzkarCategoryScreenState extends State<AzkarCategoryScreen> {
  final _listKey = GlobalKey<AnimatedListState>();
  late final List<DhikrItem> _items;
  late final Map<String, int> _remaining;
  final Set<String> _removingIds = <String>{};
  int _completed = 0;
  bool _showCompletion = false;

  @override
  void initState() {
    super.initState();
    _items = List<DhikrItem>.of(widget.category.items);
    _remaining = {for (final item in _items) item.id: item.target};
  }

  void _count(DhikrItem item) {
    final current = _remaining[item.id];
    final index = _items.indexWhere((candidate) => candidate.id == item.id);
    if (current == null || current <= 0 || index < 0 || _removingIds.contains(item.id)) {
      return;
    }

    if (current > 1) {
      setState(() => _remaining[item.id] = current - 1);
      return;
    }

    _removingIds.add(item.id);
    _items.removeAt(index);
    _remaining.remove(item.id);
    _completed++;

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _RemovingDhikrCard(
        item: item,
        categoryIcon: widget.category.icon,
        animation: animation,
      ),
      duration: const Duration(milliseconds: 360),
    );

    if (mounted) setState(() {});

    if (_items.isEmpty) {
      Future<void>.delayed(const Duration(milliseconds: 380), () {
        if (mounted) setState(() => _showCompletion = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    final s = S.of(context);
    final total = widget.category.items.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(categoryTitle(s, widget.category.id)),
        backgroundColor: Colors.transparent,
        foregroundColor: colors.primary,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _backgroundGradient(context),
            stops: const [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: _showCompletion
                ? _Completion(
                    colors: colors,
                    title: categoryTitle(s, widget.category.id),
                  )
                : Column(
                    children: [
                      _ProgressHeader(
                        colors: colors,
                        completed: _completed,
                        total: total,
                        remaining: _items.length,
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: AnimatedList(
                          key: _listKey,
                          initialItemCount: _items.length,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemBuilder: (context, index, animation) {
                            final item = _items[index];
                            return SizeTransition(
                              sizeFactor: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: DhikrCard(
                                  item: item,
                                  remaining: _remaining[item.id] ?? 0,
                                  categoryIcon: widget.category.icon,
                                  onTap: () => _count(item),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
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

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.colors,
    required this.completed,
    required this.total,
    required this.remaining,
  });

  final _AzkarColors colors;
  final int completed;
  final int total;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${s.progress}: $completed / $total',
                style: TextStyle(color: colors.secondary, fontSize: 13),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$remaining ${s.remaining}',
                style: TextStyle(
                  color: colors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: total == 0 ? 0 : completed / total,
            color: colors.accent,
            backgroundColor: colors.surface,
          ),
        ),
      ],
    );
  }
}

class DhikrCard extends StatelessWidget {
  const DhikrCard({
    super.key,
    required this.item,
    required this.remaining,
    this.categoryIcon,
    this.onTap,
    this.enabled = true,
  });

  final DhikrItem item;
  final int remaining;
  final IconData? categoryIcon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = _cardColors(context);
    final s = S.of(context);

    return Semantics(
      button: enabled,
      label: '${s.tapToCount}. ${item.arabic}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.accent.withValues(alpha: .18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      categoryIcon ?? Icons.auto_awesome_outlined,
                      color: colors.accent,
                      size: 24,
                    ),
                    const Spacer(),
                    _RemainingBadge(remaining: remaining, colors: colors),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  item.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 22,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.source != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${s.source}: ${item.source}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.secondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      color: colors.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        s.tapToCount,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _AzkarColors _cardColors(BuildContext context) {
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

class _RemainingBadge extends StatelessWidget {
  const _RemainingBadge({required this.remaining, required this.colors});

  final int remaining;
  final _AzkarColors colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey(remaining),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: colors.accent.withValues(alpha: .20)),
        ),
        child: Text(
          '$remaining×',
          style: TextStyle(
            color: colors.accent,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RemovingDhikrCard extends StatelessWidget {
  const _RemovingDhikrCard({
    required this.item,
    required this.categoryIcon,
    required this.animation,
  });

  final DhikrItem item;
  final IconData categoryIcon;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DhikrCard(
            item: item,
            remaining: 0,
            categoryIcon: categoryIcon,
            enabled: false,
          ),
        ),
      ),
    );
  }
}

class _Completion extends StatelessWidget {
  const _Completion({required this.colors, required this.title});

  final _AzkarColors colors;
  final String title;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: .12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: .28),
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.completed,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.primary,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.secondary, fontSize: 16),
            ),
            const SizedBox(height: 26),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(s.navAzkar),
            ),
          ],
        ),
      ),
    );
  }
}

String categoryTitle(S s, AzkarCategoryId id) {
  switch (id) {
    case AzkarCategoryId.morning:
      return s.azkarMorning;
    case AzkarCategoryId.evening:
      return s.azkarEvening;
    case AzkarCategoryId.sleep:
      return s.azkarSleep;
    case AzkarCategoryId.prayer:
      return s.azkarPrayer;
    case AzkarCategoryId.duas:
      return s.azkarDuas;
    case AzkarCategoryId.toilet:
      return s.azkarToilet;
    case AzkarCategoryId.daily:
      return s.azkarDaily;
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
