import 'package:flutter/material.dart';
import 'package:nidaa_v2/azkar/domain/entities/azkar_entities.dart';
import 'package:nidaa_v2/azkar/presentation/screens/azkar_category_screen.dart';
import 'package:nidaa_v2/location/manual_location/presentation/screens/manual_location_screen.dart';
import 'package:nidaa_v2/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:nidaa_v2/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:nidaa_v2/routes/app_routes.dart';

/// Callbacks and values the root route needs from the application shell.
///
/// This keeps [AppRouter] free of app state while still allowing the root
/// route to be generated centrally instead of being hardcoded in `MaterialApp`.
class AppRouterDependencies {
  const AppRouterDependencies({
    required this.showOnboarding,
    required this.onOnboardingComplete,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
  });

  final bool showOnboarding;
  final VoidCallback onOnboardingComplete;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
}

/// Centralized route generation for the application.
///
/// Only route-to-page mapping lives here; route names are defined in
/// [AppRoutes] and the application shell owns configuration.
class AppRouter {
  const AppRouter._();

  /// Builds the [Route] for [settings] using the centralized route table.
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    AppRouterDependencies dependencies,
  ) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => dependencies.showOnboarding
              ? OnboardingScreen(onComplete: dependencies.onOnboardingComplete)
              : PrayerTimesScreen(
                  themeMode: dependencies.themeMode,
                  onThemeModeChanged: dependencies.onThemeModeChanged,
                  locale: dependencies.locale,
                  onLocaleChanged: dependencies.onLocaleChanged,
                ),
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) =>
              OnboardingScreen(onComplete: dependencies.onOnboardingComplete),
        );

      case AppRoutes.azkarCategory:
        final category = settings.arguments;
        if (category is! AzkarCategory) {
          return _unknownRoute(settings);
        }
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => AzkarCategoryScreen(category: category),
        );

      case AppRoutes.manualLocation:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const ManualLocationScreen(),
        );

      default:
        return _unknownRoute(settings);
    }
  }

  /// Fallback used when a route name is not registered or its arguments are
  /// invalid. Keeps the app from crashing on unknown routes.
  static Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(child: Text('No route defined for "${settings.name}"')),
      ),
    );
  }
}
