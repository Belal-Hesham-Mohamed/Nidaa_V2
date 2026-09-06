import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/location/manual_location/presentation/screens/manual_location_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
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
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _openLocationFlow() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ManualLocationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final accentColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentBlue;

    return Scaffold(
      backgroundColor: backgroundColor.withValues(alpha: 0.16),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: primaryText,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _SectionTitle(title: 'Theme', color: primaryText),
          const SizedBox(height: 10),
          _ChoiceRow<ThemeMode>(
            options: const [
              _Choice(label: 'Light', value: ThemeMode.light),
              _Choice(label: 'Dark', value: ThemeMode.dark),
              _Choice(label: 'Device', value: ThemeMode.system),
            ],
            selectedValue: widget.themeMode,
            onSelected: widget.onThemeModeChanged,
            surfaceColor: surfaceColor,
            selectedColor: accentColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: 'Language', color: primaryText),
          const SizedBox(height: 10),
          _ChoiceRow<Locale>(
            options: const [
              _Choice(label: 'English', value: Locale('en')),
              _Choice(
                label: '\u{627}\u{644}\u{639}\u{631}\u{628}\u{64A}\u{629}',
                value: Locale('ar'),
              ),
            ],
            selectedValue: widget.locale,
            onSelected: widget.onLocaleChanged,
            surfaceColor: surfaceColor,
            selectedColor: accentColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: 'Location', color: primaryText),
          const SizedBox(height: 10),
          _SettingsRow(
            title: 'Location',
            description: 'Choose your location for accurate prayer times.',
            onTap: _openLocationFlow,
            cardColor: cardColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
            accentColor: accentColor,
          ),
          const SizedBox(height: 12),
          _SettingsRow(
            title: 'Permissions',
            description: 'Manage app permissions',
            onTap: () {},
            cardColor: cardColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
            accentColor: accentColor,
          ),
          const SizedBox(height: 12),
          _SettingsRow(
            title: 'About Nidaa',
            description: 'App information, privacy, and more',
            onTap: () {},
            cardColor: cardColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _Choice<T> {
  const _Choice({required this.label, required this.value});

  final String label;
  final T value;
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    required this.surfaceColor,
    required this.selectedColor,
    required this.primaryText,
    required this.secondaryText,
  });

  final List<_Choice<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final Color surfaceColor;
  final Color selectedColor;
  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options
          .map(
            (option) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: option == options.last ? 0 : 8),
                child: Material(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelected(option.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: option.value == selectedValue
                              ? selectedColor
                              : secondaryText,
                          width: option.value == selectedValue ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        option.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: option.value == selectedValue
                              ? selectedColor
                              : primaryText,
                          fontWeight: option.value == selectedValue
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.description,
    required this.onTap,
    required this.cardColor,
    required this.primaryText,
    required this.secondaryText,
    required this.accentColor,
  });

  final String title;
  final String description;
  final VoidCallback onTap;
  final Color cardColor;
  final Color primaryText;
  final Color secondaryText;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondaryText),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
