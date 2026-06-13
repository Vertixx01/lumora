import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const String _keySessionLimit = 'sessionLimit';
  static const String _keyConfirmBeforeExtending = 'confirmBeforeExtending';
  static const String _keyHideReels = 'hideReels';
  static const String _keyHideExplore = 'hideExplore';
  static const String _keyHideSuggested = 'hideSuggested';
  static const String _keyHideSponsored = 'hideSponsored';
  static const String _keyHideLiveShopping = 'hideLiveShopping';
  static const String _keyDisableAutoplay = 'disableAutoplay';
  static const String _keyOpenLinksExternally = 'openLinksExternally';
  static const String _keyHapticsEnabled = 'hapticsEnabled';
  static const String _keyCookieBackupEnabled = 'cookieBackupEnabled';
  static const String _keyBaselineMinutes = 'baselineMinutes';
  static const String _keyHasCompletedOnboarding = 'hasCompletedOnboarding';

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'sessionLimit': prefs.getInt(_keySessionLimit) ?? 20,
      'confirmBeforeExtending':
          prefs.getBool(_keyConfirmBeforeExtending) ?? true,
      'hideReels': prefs.getBool(_keyHideReels) ?? true,
      'hideExplore': prefs.getBool(_keyHideExplore) ?? true,
      'hideSuggested': prefs.getBool(_keyHideSuggested) ?? true,
      'hideSponsored': prefs.getBool(_keyHideSponsored) ?? true,
      'hideLiveShopping': prefs.getBool(_keyHideLiveShopping) ?? true,
      'disableAutoplay': prefs.getBool(_keyDisableAutoplay) ?? true,
      'openLinksExternally': prefs.getBool(_keyOpenLinksExternally) ?? true,
      'hapticsEnabled': prefs.getBool(_keyHapticsEnabled) ?? true,
      'cookieBackupEnabled': prefs.getBool(_keyCookieBackupEnabled) ?? true,
      'baselineMinutes': prefs.getInt(_keyBaselineMinutes) ?? 20,
      'hasCompletedOnboarding':
          prefs.getBool(_keyHasCompletedOnboarding) ?? false,
    };
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
