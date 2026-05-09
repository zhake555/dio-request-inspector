import 'package:dio_request_inspector/src/model/copy_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CopySettingsStorage {
  static const _keyRequestHeaders = 'dri_copy_request_headers';
  static const _keyResponseHeaders = 'dri_copy_response_headers';
  static const _keyExcludedHeaders = 'dri_copy_excluded_headers';

  static CopySettings _current = const CopySettings();

  static CopySettings get current => _current;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _current = CopySettings(
      copyRequestHeaders: prefs.getBool(_keyRequestHeaders) ?? true,
      copyResponseHeaders: prefs.getBool(_keyResponseHeaders) ?? true,
      excludedHeaders:
          prefs.getStringList(_keyExcludedHeaders) ?? ['authorization'],
    );
  }

  static Future<void> save(CopySettings settings) async {
    _current = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRequestHeaders, settings.copyRequestHeaders);
    await prefs.setBool(_keyResponseHeaders, settings.copyResponseHeaders);
    await prefs.setStringList(_keyExcludedHeaders, settings.excludedHeaders);
  }
}
