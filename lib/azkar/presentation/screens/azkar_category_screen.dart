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

  DhikrItem get _item => widget.category.items[_index];

  void _moveNext() {
    if (_index >= widget.category.items.length - 1) return;
    setState(() => _index++);
  }

  void _movePrevious() {
    if (_index <= 0) return;
    setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    final s = S.of(context);
    final isLast = _index == widget.category.items.length - 1;

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
                    '${_item.target}×',
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (_index + 1) / widget.category.items.length,
                color: colors.accent,
                backgroundColor: colors.surface,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _moveNext,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
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
                            isLast
                                ? Icons.check_circle_outline
                                : widget.category.icon,
                            color: isLast
                                ? AppColors.success
                                : colors.accent,
                            size: 34,
                          ),
                          const SizedBox(height: 26),
                          Text(
                            _item.arabic,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 25,
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
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_item.target}×',
                              style: TextStyle(
                                color: colors.accent,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            isLast ? s.completed : 'اضغط للذكر التالي',
                            style: TextStyle(color: colors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: _index > 0 ? _movePrevious : null,
                    icon: const Icon(Icons.arrow_back),
                    color: colors.primary,
                  ),
                  const Spacer(),
                  if (!isLast)
                    FilledButton.icon(
                      onPressed: _moveNext,
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
