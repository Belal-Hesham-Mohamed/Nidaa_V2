import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/core/dependency_injection.dart';
import 'package:nidaa_v2/core/settings/settings_local_datasource.dart';
import 'package:nidaa_v2/generated/l10n.dart';
import 'package:nidaa_v2/location/current_location/data/models/location_model.dart';
import 'package:nidaa_v2/location/manual_location/data/models/manual_location_model.dart';
import 'package:nidaa_v2/prayer_times/data/models/prayer_times_model.dart';
import 'package:nidaa_v2/prayer_times/presentation/screens/prayer_times_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(LocationModelAdapter());
  Hive.registerAdapter(ManualLocationModelAdapter());
  Hive.registerAdapter(PrayerTimesModelAdapter());
  Hive.registerAdapter(TimingsModelAdapter());
  Hive.registerAdapter(DateModelAdapter());
  Hive.registerAdapter(NightModelAdapter());

  await Hive.openBox<LocationModel>('locationBox');
  await Hive.openBox<String>('locationModeBox');
  await Hive.openBox<ManualLocationModel>('manualLocationBox');
  await Hive.openBox('prayerTimesBox');

  final settingsLocalDataSource = await SettingsLocalDataSource.init();
  setupServiceLocator(settingsLocalDataSource);

  runApp(MyApp(settingsLocalDataSource: settingsLocalDataSource));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.settingsLocalDataSource});

  final SettingsLocalDataSource settingsLocalDataSource;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    final savedCode = widget.settingsLocalDataSource.getLocaleCode();
    _locale = Locale(savedCode ?? 'en');
  }

  Future<void> _setLocale(Locale locale) async {
    await widget.settingsLocalDataSource.saveLocaleCode(locale.languageCode);
    if (!mounted) return;
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
      onGenerateTitle: (context) => S.of(context).appTitle,
      locale: _locale,
      themeMode: _themeMode,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: ColorScheme.light(
          primary: AppColors.lightAccentBlue,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightPrimaryText,
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.dark(
          primary: AppColors.darkAccentGold,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkPrimaryText,
        ),
      ),
      home: PrayerTimesScreen(
        themeMode: _themeMode,
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
        locale: _locale,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}