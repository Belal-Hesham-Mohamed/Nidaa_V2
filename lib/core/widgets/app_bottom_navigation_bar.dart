import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/generated/l10n.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navigationColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final inactiveColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final activeColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentBlue;

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: navigationColor,
          border: Border(
            top: BorderSide(
              color: activeColor.withValues(alpha: 0.10),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          height: 72,
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: navigationColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: activeColor.withValues(alpha: 0.12),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.access_time, color: inactiveColor),
              selectedIcon: Icon(Icons.access_time, color: activeColor),
              label: s.navPrayerTimes,
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: inactiveColor),
              selectedIcon: Icon(Icons.explore, color: activeColor),
              label: s.navQibla,
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined, color: inactiveColor),
              selectedIcon: Icon(Icons.menu_book, color: activeColor),
              label: s.navAzkar,
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: inactiveColor),
              selectedIcon: Icon(Icons.settings, color: activeColor),
              label: s.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
