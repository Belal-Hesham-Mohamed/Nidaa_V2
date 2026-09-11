import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nidaa_v2/azkar/domain/entities/azkar_entities.dart';
import 'package:nidaa_v2/azkar/presentation/screens/azkar_category_screen.dart';
import 'package:nidaa_v2/generated/l10n.dart';

void main() {
  final longArabic = List.filled(20, 'آية الكرسي').join(' ');
  final category = AzkarCategory(
    id: AzkarCategoryId.morning,
    icon: Icons.wb_sunny_outlined,
    items: [
      DhikrItem(id: 'one', arabic: 'ذكر واحد', target: 3, source: 'مصدر'),
      DhikrItem(id: 'two', arabic: 'ذكر اثنان', target: 1),
      DhikrItem(id: 'many', arabic: 'ذكر كثير', target: 100),
      DhikrItem(id: 'long', arabic: longArabic, target: 1),
    ],
  );

  testWidgets(
    'renders all cards in a vertical scroll and counts independently',
    (tester) async {
      await tester.pumpWidget(_app(category));
      expect(find.text('ذكر واحد'), findsOneWidget);
      expect(find.byType(Scrollable), findsOneWidget);
      expect(find.byType(PageView), findsNothing);

      await tester.tap(find.text('ذكر واحد'));
      await tester.pump();
      expect(find.text('2×'), findsOneWidget);
      expect(find.text('100×'), findsOneWidget);

      await tester.tap(find.text('ذكر واحد'));
      await tester.pump();
      expect(find.text('1×'), findsOneWidget);
      await tester.tap(find.text('ذكر واحد'));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('ذكر واحد'), findsNothing);
      expect(find.text('ذكر اثنان'), findsOneWidget);
    },
  );

  testWidgets('target one is removed and target 100 becomes 99', (
    tester,
  ) async {
    await tester.pumpWidget(_app(category));
    await tester.tap(find.text('ذكر اثنان'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('ذكر اثنان'), findsNothing);
    await tester.scrollUntilVisible(find.text('ذكر كثير'), 300, scrollable: find.byType(Scrollable));
    await tester.tap(find.text('ذكر كثير'));
    await tester.pump();
    expect(find.text('99×'), findsOneWidget);
  });

  testWidgets(
    'long Arabic content has no overflow on a small Arabic viewport',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_app(category, locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.textContaining('آية الكرسي'), 300, scrollable: find.byType(Scrollable));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(Scrollable), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('large text scale still renders without overflow', (tester) async {
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2.2)),
      child: _app(category),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('completing every card shows completion without navigation', (
    tester,
  ) async {
    final small = AzkarCategory(
      id: AzkarCategoryId.daily,
      icon: Icons.menu_book,
      items: const [DhikrItem(id: 'only', arabic: 'ذكر', target: 1)],
    );
    await tester.pumpWidget(_app(small));
    await tester.tap(find.text('ذكر'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Completed'), findsOneWidget);
    expect(find.byType(AzkarCategoryScreen), findsOneWidget);
  });
}

Widget _app(AzkarCategory category, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: AzkarCategoryScreen(category: category),
  );
}
