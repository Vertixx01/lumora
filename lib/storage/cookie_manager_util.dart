import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookieManagerUtil {
  static const String _keyCookieBackupPrefix = 'lumora_cookies_';

  static Future<void> backupCookies(String urlString) async {
    try {
      final url = WebUri(urlString);
      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(url: url);

      if (cookies.isNotEmpty) {
        final List<Map<String, dynamic>> cookieListMap = [];
        for (final cookie in cookies) {
          cookieListMap.add({
            'name': cookie.name,
            'value': cookie.value,
            'domain': cookie.domain,
            'path': cookie.path,
            'isSecure': cookie.isSecure,
            'isHttpOnly': cookie.isHttpOnly,
            'expiresDate': cookie.expiresDate,
          });
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          '$_keyCookieBackupPrefix$urlString',
          jsonEncode(cookieListMap),
        );
      }
    } catch (e) {
      // Fail-soft
    }
  }

  static Future<void> restoreCookies(String urlString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_keyCookieBackupPrefix$urlString');
      if (raw == null) return;

      final List<dynamic> cookieListMap = jsonDecode(raw);
      final url = WebUri(urlString);
      final cookieManager = CookieManager.instance();

      for (final rawCookie in cookieListMap) {
        await cookieManager.setCookie(
          url: url,
          name: rawCookie['name'],
          value: rawCookie['value'],
          domain: rawCookie['domain'] ?? '.instagram.com',
          path: rawCookie['path'] ?? '/',
          isSecure: rawCookie['isSecure'] ?? true,
          isHttpOnly: rawCookie['isHttpOnly'] ?? false,
          expiresDate: rawCookie['expiresDate'],
        );
      }
    } catch (e) {
      // Fail-soft
    }
  }

  static Future<void> clearCookies(String urlString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyCookieBackupPrefix$urlString');

      final cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
    } catch (e) {
      // Fail-soft
    }
  }
}
