import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/generated/l10n.dart';
import 'package:nidaa_v2/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:nidaa_v2/routes/app_router.dart';
import 'package:nidaa_v2/routes/app_routes.dart';

void main() {
  for (final entryRoute in [AppRoutes.home, AppRoutes.onboarding]) {
    testWidgets('completing $entryRoute opens the main screen', (tester) async {
      var onboardingCompleted = false;
      late AppRouterDependencies dependencies;
      dependencies = AppRouterDependencies(
        showOnboarding: true,
        onOnboardingComplete: () async {
          onboardingCompleted = true;
        },
        themeMode: ThemeMode.system,
        onThemeModeChanged: (_) {},
        locale: const Locale('en'),
        onLocaleChanged: (_) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          initialRoute: entryRoute,
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.home && onboardingCompleted) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const _MainScreen(),
              );
            }
            return AppRouter.onGenerateRoute(settings, dependencies);
          },
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(onboardingCompleted, isTrue);
      expect(find.byType(_MainScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  }
}

class _MainScreen extends StatelessWidget {
  const _MainScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('Main screen'));
}
