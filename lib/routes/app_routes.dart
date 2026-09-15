/// Centralized route names for the application.
///
/// This file contains route name constants only. Page creation and
/// route-to-widget mapping live in `AppRouter` (`app_router.dart`).
///
/// Never hardcode route strings at call sites; always reference these
/// constants so route names stay consistent across the app.
class AppRoutes {
  const AppRoutes._();

  /// Root route resolved through [AppRouter] (onboarding or main shell).
  static const String home = '/';

  /// First-run onboarding flow.
  static const String onboarding = '/onboarding';

  /// Azkar category detail screen. Expects an `AzkarCategory` argument.
  static const String azkarCategory = '/azkar/category';

  /// Manual location selection flow.
  static const String manualLocation = '/location/manual';
}
