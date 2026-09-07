import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/generated/l10n.dart';

void main() {
  testWidgets('English localization loads all required keys', (tester) async {
    final s = await _loadS(tester, const Locale('en'));
    expect(s.appTitle, 'Nidaa');
    expect(s.navPrayerTimes, 'Prayer Times');
    expect(s.prayerFajr, 'Fajr');
    expect(s.retry, 'Retry');
    expect(s.manualLocationSelect('Country'), 'Select Country');
    expect(s.weekdayMonday, 'Monday');
  });

  testWidgets('Arabic localization loads all required keys', (tester) async {
    final s = await _loadS(tester, const Locale('ar'));
    expect(s.appTitle, 'نداء');
    expect(s.navPrayerTimes, 'مواقيت الصلاة');
    expect(s.prayerFajr, 'الفجر');
    expect(s.retry, 'إعادة المحاولة');
    expect(s.manualLocationSelect('الدولة'), 'اختر الدولة');
    expect(s.weekdayMonday, 'الاثنين');
  });
}

Future<S> _loadS(WidgetTester tester, Locale locale) async {
  late S loaded;
  await tester.pumpWidget(LocalizationsApp(
    locale: locale,
    onLoaded: (s) => loaded = s,
  ));
  return loaded;
}

class LocalizationsApp extends StatelessWidget {
  const LocalizationsApp({
    super.key,
    required this.locale,
    required this.onLoaded,
  });

  final Locale locale;
  final ValueChanged<S> onLoaded;

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      locale: locale,
      onGenerateRoute: (settings) => PageRouteBuilder(
        pageBuilder: (ctx, _, __) {
          onLoaded(S.of(ctx));
          return const SizedBox.shrink();
        },
      ),
      localizationsDelegates: [
        S.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      color: const Color(0xFFFFFFFF),
    );
  }
}