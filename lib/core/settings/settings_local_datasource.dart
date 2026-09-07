import 'package:hive/hive.dart';

class SettingsLocalDataSource {
  static const String _boxName = 'settingsBox';
  static const String _localeKey = 'locale';

  final Box _box;

  SettingsLocalDataSource(this._box);

  static Future<SettingsLocalDataSource> init() async {
    final box = await Hive.openBox(_boxName);
    return SettingsLocalDataSource(box);
  }

  String? getLocaleCode() {
    final value = _box.get(_localeKey);
    if (value is String && (value == 'en' || value == 'ar')) {
      return value;
    }
    return null;
  }

  Future<void> saveLocaleCode(String code) async {
    await _box.put(_localeKey, code);
  }
}