import 'package:flutter/material.dart';
import '../storage/settings_storage.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsStorage _storage = SettingsStorage();

  int _sessionLimit = 20;
  bool _confirmBeforeExtending = true;
  bool _hideReels = true;
  bool _hideExplore = true;
  bool _hideSuggested = true;
  bool _hideSponsored = true;
  bool _hideLiveShopping = true;
  bool _disableAutoplay = true;
  bool _openLinksExternally = true;
  bool _hapticsEnabled = true;
  bool _cookieBackupEnabled = true;
  int _baselineMinutes = 20;
  bool _hasCompletedOnboarding = false;

  bool _isInitialized = false;

  // Getters
  int get sessionLimit => _sessionLimit;
  bool get confirmBeforeExtending => _confirmBeforeExtending;
  bool get hideReels => _hideReels;
  bool get hideExplore => _hideExplore;
  bool get hideSuggested => _hideSuggested;
  bool get hideSponsored => _hideSponsored;
  bool get hideLiveShopping => _hideLiveShopping;
  bool get disableAutoplay => _disableAutoplay;
  bool get openLinksExternally => _openLinksExternally;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get cookieBackupEnabled => _cookieBackupEnabled;
  int get baselineMinutes => _baselineMinutes;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isInitialized => _isInitialized;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.loadSettings();
    _sessionLimit = settings['sessionLimit'];
    _confirmBeforeExtending = settings['confirmBeforeExtending'];
    _hideReels = settings['hideReels'];
    _hideExplore = settings['hideExplore'];
    _hideSuggested = settings['hideSuggested'];
    _hideSponsored = settings['hideSponsored'];
    _hideLiveShopping = settings['hideLiveShopping'];
    _disableAutoplay = settings['disableAutoplay'];
    _openLinksExternally = settings['openLinksExternally'];
    _hapticsEnabled = settings['hapticsEnabled'];
    _cookieBackupEnabled = settings['cookieBackupEnabled'];
    _baselineMinutes = settings['baselineMinutes'];
    _hasCompletedOnboarding = settings['hasCompletedOnboarding'];
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> updateSetting(String key, dynamic value) async {
    switch (key) {
      case 'sessionLimit':
        _sessionLimit = value as int;
        break;
      case 'confirmBeforeExtending':
        _confirmBeforeExtending = value as bool;
        break;
      case 'hideReels':
        _hideReels = value as bool;
        break;
      case 'hideExplore':
        _hideExplore = value as bool;
        break;
      case 'hideSuggested':
        _hideSuggested = value as bool;
        break;
      case 'hideSponsored':
        _hideSponsored = value as bool;
        break;
      case 'hideLiveShopping':
        _hideLiveShopping = value as bool;
        break;
      case 'disableAutoplay':
        _disableAutoplay = value as bool;
        break;
      case 'openLinksExternally':
        _openLinksExternally = value as bool;
        break;
      case 'hapticsEnabled':
        _hapticsEnabled = value as bool;
        break;
      case 'cookieBackupEnabled':
        _cookieBackupEnabled = value as bool;
        break;
      case 'baselineMinutes':
        _baselineMinutes = value as int;
        break;
      case 'hasCompletedOnboarding':
        _hasCompletedOnboarding = value as bool;
        break;
    }
    notifyListeners();
    await _storage.saveSetting(key, value);
  }

  Future<void> completeOnboarding() async {
    await updateSetting('hasCompletedOnboarding', true);
  }

  Future<void> resetSettings() async {
    await _storage.clearAll();
    await _loadSettings();
  }
}
