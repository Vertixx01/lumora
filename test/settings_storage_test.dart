import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumora/storage/settings_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads privacy-preserving defaults', () async {
    final storage = SettingsStorage();

    final settings = await storage.loadSettings();

    expect(settings['sessionLimit'], 20);
    expect(settings['hideReels'], isTrue);
    expect(settings['hideExplore'], isTrue);
    expect(settings['hideSuggested'], isTrue);
    expect(settings['hideSponsored'], isTrue);
    expect(settings['disableAutoplay'], isTrue);
    expect(settings['cookieBackupEnabled'], isTrue);
    expect(settings['hasCompletedOnboarding'], isFalse);
  });

  test('saves and reloads scalar settings', () async {
    final storage = SettingsStorage();

    await storage.saveSetting('sessionLimit', 30);
    await storage.saveSetting('cookieBackupEnabled', false);

    final settings = await storage.loadSettings();

    expect(settings['sessionLimit'], 30);
    expect(settings['cookieBackupEnabled'], isFalse);
  });
}
