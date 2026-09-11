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
  int _index = 0;
  int _count = 0;

  DhikrItem get _item => widget.category.items[_index];

  void _increment() {
    if (_count >= _item.target) return;
    setState(() => _count++);
  }

  void _move(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.category.items.length) return;
    setState(() {
      _index = next;
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    final s = S.of(context);
    final completed = _count >= _item.target;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(categoryTitle(s, widget.category.id)),
        backgroundColor: colors.background,
        foregroundColor: colors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_index + 1} / ${widget.category.items.length}',
                      style: TextStyle(color: colors.secondary),
                    ),
                  ),
                  Text(
                    '${s.progress}: ${_count}/${_item.target}',
                    style: TextStyle(color: colors.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _count / _item.target,
                color: colors.accent,
                backgroundColor: colors.surface,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: InkWell(
                  onTap: _increment,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colors.accent.withValues(alpha: .18),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          completed
                              ? Icons.check_circle_outline
                              : widget.category.icon,
                          color: completed ? AppColors.success : colors.accent,
                          size: 34,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          _item.arabic,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 26,
                            height: 1.9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_item.source != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            '${s.source}: ${_item.source}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.secondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        Text(
                          completed
                              ? s.completed
                              : '${_count} / ${_item.target}',
                          style: TextStyle(
                            color: completed
                                ? AppColors.success
                                : colors.accent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.tapToCount,
                          style: TextStyle(color: colors.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _index > 0 ? () => _move(-1) : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  FilledButton.icon(
                    onPressed:
                        completed && _index < widget.category.items.length - 1
                        ? () => _move(1)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(s.next),
                  ),
                ],
              ),
            ],
          ),
        ),
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
