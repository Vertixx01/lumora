import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ConfigProvider extends ChangeNotifier {
  static const String _keyCachedConfig = 'cached_selector_config';
  static const String _remoteConfigUrl =
      'https://raw.githubusercontent.com/vertixx01/lumora/main/networks/instagram.selectors.json';

  Map<String, dynamic> _config = {};
  bool _isLoading = true;

  Map<String, dynamic> get config => _config;
  bool get isLoading => _isLoading;

  String get configVersion => _config['configVersion'] ?? '0.0.0';

  ConfigProvider() {
    _init();
  }

  // Offline default selectors for Instagram
  static const Map<String, dynamic> _defaultConfig = {
    'configVersion': '2026.06.12.1',
    'network': 'instagram',
    'selectors': {
      'feedContainer': [
        '[role="feed"]',
        '[role="main"] > div',
        'main > div > section',
      ],
      'postItem': ['[role="article"]', 'article'],
      'reelsTab': [
        'a[href="/reels/"]',
        'a[href="/reels"]',
        'a[href^="/reels"]',
        'a[href*="/reels/"]',
        'a[href*="/reels"]',
        'a[href*="reels"]',
        '[aria-label*="Reels"]',
        '[aria-label*="reels"]',
        '[aria-label*="Reel"]',
        '[aria-label*="reel"]',
      ],
      'exploreTab': [
        'a[href="/explore/"]',
        'a[href="/explore"]',
        'a[href^="/explore"]',
        'a[href*="/explore/"]',
        'a[href*="/explore"]',
        '[aria-label*="Explore"]',
        '[aria-label*="explore"]',
      ],
      'suggestedPosts': ['[role="article"]', 'article'],
      'sponsoredPosts': ['[role="article"]', 'article'],
      'liveAndShopping': [
        'a[href*="/shopping/"]',
        '[aria-label*="Shop"]',
        '[aria-label*="shop"]',
      ],
      'videoNodes': ['video', '[role="presentation"] video'],
    },
    'labelMap': {
      'sponsored': [
        'Ad',
        'Sponsored',
        'Paid partnership',
        'Gesponsert',
        'Sponsorisé',
        'Sponsorizzato',
        'Patrocinado',
      ],
      'suggested': [
        'Suggested for you',
        'Empfohlen für dich',
        'Suggestions pour vous',
        'Suggeriti per te',
        'Sugerencias para ti',
      ],
    },
  };

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(_keyCachedConfig);

    if (cachedString != null) {
      try {
        final parsed = jsonDecode(cachedString) as Map<String, dynamic>;
        if (parsed.containsKey('selectors') &&
            parsed['selectors'] is Map &&
            (parsed['selectors'] as Map).isNotEmpty) {
          _config = parsed;
        } else {
          _config = Map<String, dynamic>.from(_defaultConfig);
        }
      } catch (_) {
        _config = Map<String, dynamic>.from(_defaultConfig);
      }
    } else {
      _config = Map<String, dynamic>.from(_defaultConfig);
    }

    _isLoading = false;
    notifyListeners();

    // Trigger background fetch to get latest selectors
    _fetchRemoteConfig();
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      final response = await http
          .get(Uri.parse(_remoteConfigUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final remote = jsonDecode(response.body) as Map<String, dynamic>;
        final String remoteVersion = remote['configVersion'] ?? '0.0.0';
        final String currentVersion = _config['configVersion'] ?? '0.0.0';

        // Validate remote config contains valid selectors mapping
        if (remote.containsKey('selectors') &&
            remote['selectors'] is Map &&
            (remote['selectors'] as Map).isNotEmpty) {
          // Lexicographical date comparison (YYYY.MM.DD.N)
          if (remoteVersion.compareTo(currentVersion) > 0) {
            _config = remote;
            notifyListeners();

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_keyCachedConfig, jsonEncode(remote));
          }
        }
      }
    } catch (_) {
      // Fail-soft: keep current config on any network or parse failure
    }
  }

  List<String> getSelectors(String category) {
    if (_config['selectors'] == null ||
        _config['selectors'][category] == null) {
      return [];
    }
    return List<String>.from(_config['selectors'][category]);
  }

  List<String> getLabels(String type) {
    if (_config['labelMap'] == null || _config['labelMap'][type] == null) {
      return [];
    }
    return List<String>.from(_config['labelMap'][type]);
  }
}
