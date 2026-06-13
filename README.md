<p align="center">
  <img src="assets/lumora_logo.png" alt="Lumora logo" width="112" height="112">
</p>

<h1 align="center">Lumora</h1>

<p align="center">
  Your social feeds, without the undertow.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white">
  <img alt="Android" src="https://img.shields.io/badge/Android-8.0%2B-3DDC84?logo=android&logoColor=white">
  <img alt="Version" src="https://img.shields.io/badge/version-1.0.0-FD7979">
  <img alt="License" src="https://img.shields.io/badge/license-AGPL--3.0-181211">
</p>

<p align="center">
  <img src="assets/icons/instagram.svg" alt="Instagram" width="18" height="18">
  <strong>Instagram-first</strong> distraction filtering for the official mobile web app.
</p>

## What It Is

Lumora is a privacy-first Flutter app that opens the official mobile web version of social platforms inside an in-app WebView, then applies local-only controls that reduce distracting surfaces.

The app starts with Instagram support. It can hide or soften Reels entry points, Explore surfaces, suggested posts, ads, live/shopping modules, autoplay video, and long feed sessions. You still use the real Instagram site, with your own login session, inside a calmer shell.

Lumora does not scrape APIs, proxy traffic, run a backend, or collect analytics.

## Current Status

| Area | Status |
| --- | --- |
| Release version | `1.0.0` |
| First supported network | Instagram mobile web |
| Platforms | Android-first Flutter app, iOS project scaffold present |
| Backend | None |
| License | AGPL-3.0 |
| Data model | Local settings, local session history, local optional cookie backup |

## Features

| Feature | What It Does |
| --- | --- |
| Instagram WebView | Loads `instagram.com` with a mobile user agent inside Lumora |
| Home app picker | Lets the user choose a supported social app, currently Instagram |
| Distraction toggles | Per-feature controls for Reels, Explore, suggested posts, sponsored posts, shopping/live, and autoplay |
| Post session cap | Counts posts viewed and shows a caught-up moment when the configured limit is reached |
| Insights | Shows local session history, time-saved estimates, and usage patterns |
| Local cookie backup | Optional WebView cookie backup for devices that aggressively clear WebView state |
| Remote selector config | Instagram selectors can be updated through JSON without changing core app code |
| Privacy-first defaults | No telemetry, no accounts, no backend, no cross-device sync |

## How It Works

Lumora uses three layers:

| Layer | Role |
| --- | --- |
| Flutter shell | Routing, settings, app picker, insights, loading states, and session UI |
| In-app WebView | Loads the real mobile Instagram website |
| Injection script | Applies local CSS/JS rules to hide selected surfaces and count viewed posts |

The injected script is generated from:

```text
lib/injection/build_injection_script.dart
```

Instagram selector configuration lives in:

```text
networks/instagram.selectors.json
lib/store/config_provider.dart
```

The remote config path is used when available, and the embedded local defaults are used as a fallback.

## Privacy

Lumora is designed around a simple rule: your social activity should stay on your device.

- No backend.
- No telemetry.
- No analytics SDK.
- No Lumora account.
- No platform API scraping.
- No credential handling outside the official platform login page.
- Settings are stored with `shared_preferences`.
- Session history is stored locally as JSON.
- Cookie backup is optional and local-only.

If selector injection breaks, Lumora should fail soft by showing the official site instead of blocking access.

## Project Structure

```text
lumora/
├── assets/
│   ├── lumora_logo.png
│   └── icons/instagram.svg
├── lib/
│   ├── components/              # Shared UI components
│   ├── injection/               # WebView injection script builder
│   ├── screens/                 # Home, WebView, Settings, Insights, Onboarding
│   ├── storage/                 # Settings, sessions, cookie backup
│   ├── store/                   # Provider state models
│   ├── theme/                   # Colors and ThemeData
│   ├── app_info.dart            # App version constants
│   └── main.dart                # App entrypoint and routes
├── networks/
│   └── instagram.selectors.json # Remote-updatable selector schema
├── test/
│   ├── injection_script_test.dart
│   ├── session_record_test.dart
│   └── settings_storage_test.dart
├── android/
├── ios/
├── PROJECT.MD
├── docs/RESEARCH.md
└── README.md
```

## Requirements

- Flutter SDK 3.x
- Dart SDK 3.12 compatible
- Android Studio or Android SDK tools
- Android 8.0+ device or emulator for Android testing

Check your setup:

```sh
flutter doctor
flutter devices
```

## Development

Install dependencies:

```sh
flutter pub get
```

Run checks:

```sh
dart format lib test
flutter analyze
flutter test
```

Run on a connected device or emulator:

```sh
flutter run
```

Run on a specific Android target:

```sh
flutter devices
flutter run -d <device_id>
```

For example:

```sh
flutter run -d emulator-5554
```

## Android Builds

Build a debug APK:

```sh
flutter build apk --debug
```

Debug APK output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Install it manually:

```sh
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Install it to a specific device:

```sh
adb -s <device_id> install -r build/app/outputs/flutter-apk/app-debug.apk
```

Build a release APK:

```sh
cp android/key.properties.example android/key.properties
# Edit android/key.properties so it points at your release keystore.
flutter build apk --release
```

Without `android/key.properties`, Gradle can produce an unsigned release APK for inspection, but it is not suitable for distribution.

## Selector Config

Instagram changes its web DOM often, so Lumora avoids brittle class-name selectors where possible. The selector strategy is:

| Priority | Selector Type | Why |
| --- | --- | --- |
| 1 | ARIA and semantic HTML | More stable and accessibility-driven |
| 2 | URL patterns | Useful for Reels, posts, Explore, and Shopping entry points |
| 3 | Text labels | Needed for sponsored and suggested content |
| 4 | Structural fallback | Used carefully when the page shape changes |

When editing selectors:

- Prefer `article`, `[role="article"]`, ARIA labels, and stable href patterns.
- Avoid broad selectors that can hide feed media or root containers.
- Keep `lib/store/config_provider.dart` in sync with `networks/instagram.selectors.json` when changing offline defaults.
- Add or update tests in `test/injection_script_test.dart` for risky behavior.

## Testing Notes

Useful commands while working on WebView injection:

```sh
flutter test test/injection_script_test.dart
flutter analyze
flutter build apk --debug
```

The injection tests protect important behaviors:

- Navigation hiding must not hide post media.
- Ads and suggested posts must only hide post-shaped content.
- Viewed-post counts must survive WebView reloads and app home navigation.
- Reels permalink cards must count as viewed posts.

## Roadmap

Near-term:

- Improve post counting across more Instagram feed variants.
- Add screenshot-based manual QA notes for Android devices.
- Add selector-health tooling.
- Improve release signing documentation.

Future:

- More social networks through JSON adapters.
- Advanced insights.
- Focus schedules.
- Theme customization.
- Exportable local stats.

## Contributing

Contributions are welcome, especially around:

- Selector fixes.
- WebView reliability.
- Android device testing.
- UI polish.
- Local-only insights.

Before opening a pull request:

```sh
dart format lib test
flutter analyze
flutter test
```

## License

Lumora is licensed under the AGPL-3.0. See [LICENSE](LICENSE).
