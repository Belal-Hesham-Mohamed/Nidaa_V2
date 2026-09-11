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
  int _completed = 0;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.category.items);
    _remaining = {for (final item in _items) item.id: item.target};
  }

  void _count(DhikrItem item) {
    final count = _remaining[item.id] ?? 0;
    if (count == 0 || !_items.contains(item)) return;
    if (count > 1) {
      setState(() => _remaining[item.id] = count - 1);
      return;
    }
    final index = _items.indexOf(item);
    _listKey.currentState?.removeItem(index, (context, animation) => SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(opacity: animation, child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: DhikrCard(item: item, remaining: 0, enabled: false),
      )),
    ), duration: const Duration(milliseconds: 320));
    setState(() { _items.removeAt(index); _remaining.remove(item.id); _completed++; });
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    final s = S.of(context);
    final total = widget.category.items.length;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(categoryTitle(s, widget.category.id)), backgroundColor: colors.background, foregroundColor: colors.primary, elevation: 0),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: _items.isEmpty ? _Completion(colors: colors, title: categoryTitle(s, widget.category.id)) : Column(children: [
          Row(children: [Expanded(child: Text('${s.progress}: $_completed / $total', style: TextStyle(color: colors.secondary))), Text('${_items.length} ${s.remaining}', style: TextStyle(color: colors.accent, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _completed / total, color: colors.accent, backgroundColor: colors.surface),
          const SizedBox(height: 14),
          Expanded(child: AnimatedList(key: _listKey, initialItemCount: _items.length, padding: const EdgeInsets.only(bottom: 12), itemBuilder: (context, index, animation) {
            final item = _items[index];
            return SizeTransition(sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut), child: Padding(padding: const EdgeInsets.only(bottom: 14), child: DhikrCard(item: item, remaining: _remaining[item.id]!, categoryIcon: widget.category.icon, onTap: () => _count(item))));
          })),
        ]),
      )),
    );
  }

  _AzkarColors _colors(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _AzkarColors(dark ? AppColors.darkBackground : AppColors.lightBackground, dark ? AppColors.darkSurface : AppColors.lightSurface, dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText, dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText, dark ? AppColors.darkAccentGold : AppColors.lightAccentBlue);
  }
}

class DhikrCard extends StatelessWidget {
  const DhikrCard({super.key, required this.item, required this.remaining, this.categoryIcon, this.onTap, this.enabled = true});
  final DhikrItem item;
  final int remaining;
  final IconData? categoryIcon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = _cardColors(context);
    final s = S.of(context);
    final countBadge = Container(
      key: ValueKey(remaining),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: colors.accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
      child: Text('$remaining×', style: TextStyle(color: colors.accent, fontWeight: FontWeight.w800, fontSize: 16)),
    );
    return Semantics(
      button: enabled,
      label: s.tapToCount,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.accent.withValues(alpha: .18))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Icon(categoryIcon ?? Icons.wb_sunny_outlined, color: colors.accent, size: 24),
              const SizedBox(height: 12),
              Text(item.arabic, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: TextStyle(color: colors.primary, fontSize: 22, height: 1.8, fontWeight: FontWeight.w600)),
              if (item.source != null) ...[
                const SizedBox(height: 14),
                Text('${s.source}: ${item.source}', textAlign: TextAlign.center, style: TextStyle(color: colors.secondary, fontSize: 12, height: 1.4)),
              ],
              const SizedBox(height: 14),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: countBadge,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  _AzkarColors _cardColors(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _AzkarColors(dark ? AppColors.darkBackground : AppColors.lightBackground, dark ? AppColors.darkSurface : AppColors.lightSurface, dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText, dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText, dark ? AppColors.darkAccentGold : AppColors.lightAccentBlue);
  }
}

class _Completion extends StatelessWidget {
  const _Completion({required this.colors, required this.title});
  final _AzkarColors colors;
  final String title;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.check_circle_outline, color: AppColors.success, size: 58),
      const SizedBox(height: 16),
      Text(s.completed, style: TextStyle(color: colors.primary, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(title, textAlign: TextAlign.center, style: TextStyle(color: colors.secondary)),
      const SizedBox(height: 24),
      OutlinedButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back), label: Text(s.navAzkar)),
    ]));
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

  final Color background, surface, primary, secondary, accent;
}
