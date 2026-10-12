import 'package:shared_preferences/shared_preferences.dart';

/// Local (device) storage for simple key-value settings.
///
/// Backed by [SharedPreferences] because these settings are plain primitives
/// (`String`, `bool`) with no need for on-disk object graphs, adapters, or
/// queries that Hive is designed for.
class SettingsLocalDataSource {
  static const String _localeKey = 'locale';
  static const String _onboardingCompletedKey = 'onboardingCompleted';

  final SharedPreferences _prefs;

  SettingsLocalDataSource(this._prefs);

  /// Opens the underlying preferences store.
  ///
  /// Must be called after `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<SettingsLocalDataSource> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsLocalDataSource(prefs);
  }

  String? getLocaleCode() {
    final value = _prefs.getString(_localeKey);
    if (value == 'en' || value == 'ar') {
      return value;
    }
    return null;
  }

  Future<void> saveLocaleCode(String code) async {
    await _prefs.setString(_localeKey, code);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingCompletedKey, completed);
  }
}
