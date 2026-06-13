# PROJECT.md — Lumora

> Your social feeds, without the undertow.

---

## 0. Naming & Brand

**Name:** Lumora (from *lumen* — light/clarity — and *ora*, the boundary or threshold). The pitch: a calm, well-lit doorway into the noisy places, where you decide what enters.

**Tagline:**
- *Your social feeds, without the undertow.*
- *Social media on your terms.*
- *Scroll less. See more. Leave lighter.*

**Brand Voice:** Calm, honest, never guilt-trippy. Lumora is a tool that respects you, not a nanny that scolds you. Every piece of copy should feel like a steady friend, not a productivity drill sergeant.

This document serves as the build specification for Lumora. It defines files, schemas, signatures, and acceptance criteria for the Flutter-based implementation.

---

## 1. Product Summary

Lumora is a privacy-first, distraction-free wrapper for the social platforms you already use. It loads each platform's official mobile web app inside a WebView and surgically removes doomscroll mechanics — infinite scroll, autoplay, algorithmic rabbit holes, ads, and "suggested for you" traps — while preserving the genuinely useful parts: your feed, messages, profiles, posting, and search.

It ships Instagram-first, but is architected from day one as a multi-network platform. YouTube, X/Twitter, TikTok, Facebook, LinkedIn, Reddit, and Threads are first-class future targets, each defined by a swappable JSON adapter rather than bespoke code.

| Field | Value |
|---|---|
| Product name | Lumora |
| License | AGPL-3.0 |
| Platform | Android & iOS (Native Flutter) |
| First network | Instagram (mobile web) |
| Future networks | YouTube, X/Twitter, TikTok, Facebook, LinkedIn, Reddit, Threads |
| Backend | None. Fully on-device. |

### Core Principle (Non-Negotiable)

Lumora never scrapes, reimplements, or calls any platform's private/public APIs. It loads the real, official site in a WebView under the user's own logged-in session and modifies only the on-device presentation layer (DOM/CSS/JS). Credentials are never seen, stored, or transmitted — login happens entirely inside the platform's own pages.

---

## 2. The Hook: Why People Stay

The calm, beautiful, self-aware experience is the product. People stick with apps that make them feel good about themselves without nagging.

Three pillars drive retention:
1. **A gorgeous, frictionless shell.** The wrapper feels faster and calmer than the real app. Soft motion, generous warm tones, instant response. Closing the app feels like a natural exhale.
2. **Self-insight, not surveillance.** Lumora shows you your own patterns — time saved, sessions, streaks, what you avoided — all computed on-device, never uploaded. The positive reinforcement comes from watching yourself improve.
3. **Gentle agency.** Every limit is a suggestion you control. "Add 5 more" is always there. The app trusts the user.

---

## 3. Goals, Non-Goals & Guardrails

### Goals (v1 — Instagram)

Remove / hide:
- Reels tab and all entry points
- Explore / Discover surfaces
- Suggested posts ("You might like", "Suggested for you")
- Sponsored / ad posts (best-effort visual suppression)
- Live & Shopping modules
- Infinite scroll (replaced by a configurable session cap)
- Autoplay on all video elements

Preserve:
- Home feed (within the session cap)
- Stories (manual tap-through)
- Direct Messages
- Profiles, search, posting, likes, comments

Add (the Lumora layer):
- Per-feature toggles for everything above
- Configurable feed session cap (default 20 posts)
- A calm "You're caught up" moment at the cap
- An on-device Insights dashboard (time saved, streaks, session history)
- Remote-updatable selector config (patch without app-store review)
- Local-only data: no telemetry, no analytics, no accounts

### Non-Goals (v1)

- No backend, no cloud sync, no user accounts beyond the platform's own
- No API reimplementation or reverse engineering
- No algorithmic re-ranking (we show what the platform serves, minus blocked categories)
- No push notifications (a deliberate anti-distraction stance)
- No native Accessibility-Service injection

### Guardrails

- **Privacy by design** — no data leaves the device, ever.
- **Transparency** — fully open source; configs and injection scripts are auditable.
- **Fail-soft** — if selectors break, show the stock site rather than locking the user out. A broken wrapper must never trap someone away from their messages.
- **No dark patterns** — the app that fights dark patterns must not use them.

---

## 4. UX & UI Specification

Lumora feels like a premium meditation-adjacent app, not a browser. Calm, fast, predictable, quietly delightful.

### 4.1 Design Principles

- **Calm over stimulating.** Soft neutrals, warm accent color palette. No red badges, no urgency.
- **One primary action per screen.** Clear hierarchy, no decision fatigue.
- **Delight without dopamine traps.** Micro-animations ≤ 150 ms.
- **Exiting feels good.** "Closing the app" is a feature, designed to feel like completion.

### 4.2 Screen Map

```
First launch ──▶ Onboarding (3 cards) ──▶ Home (WebView host)
                                               │
        ┌─────────────────┬──────────────────┴──────────────────┐
        ▼                 ▼                                     ▼
   Caught-Up         Insights Dashboard                   Settings Panel
    Overlay        (Stats + Custom Sparkline)            (Toggles & Limit Slider)
```

---

## 5. Technical Architecture

### 5.1 Stack

| Layer | Choice | Notes |
|---|---|---|
| **Framework** | Flutter (Stable channel) | Single codebase; native rendering performance |
| **Language** | Dart (Sound null-safety) | Strictly typed layouts, configurations, and bridge schemas |
| **WebView** | `flutter_inappwebview` | Premium WebView controller with early script injection, AJAX intercept, and secure cookie APIs |
| **Storage** | `shared_preferences` & `path_provider` | Persistent preferences cache and file-based session logs |
| **State management** | `provider` | ChangeNotifier + consumer pattern for active state updates |
| **Design / Theme** | Built-in Material ThemeData | Customized dark theme with warm peach and coral palette |
| **Remote config** | Static JSON on GitHub Raw | Local fallback config for offline-first support |
| **Charts** | `CustomPainter` | Hand-rolled sparkline widget; keeps compilation size extremely light |
| **Android target** | minSdkVersion 26 / targetSdkVersion 35 | Android 8.0+ Oreo floor; target Android 15/16 |

---

## 6. Repository Layout

```
lumora/
├── lib/
│   ├── main.dart                 # App Entry, Routing & MultiProvider setup
│   ├── theme/
│   │   ├── colors.dart           # Warm Color Palette (#181211, #FD7979, etc.)
│   │   └── theme.dart            # ThemeData definitions for Custom Dark Theme
│   ├── store/
│   │   ├── settings_provider.dart # ChangeNotifier for settings & toggles
│   │   ├── session_provider.dart  # ChangeNotifier for active sessions & post counting
│   │   └── config_provider.dart   # ChangeNotifier for remote selector configuration
│   ├── storage/
│   │   ├── settings_storage.dart  # SharedPreferences data layer
│   │   ├── session_storage.dart   # Local file storage for historical records
│   │   └── cookie_manager_util.dart # Cookie Sync Backup/Restore for OEM resilience
│   ├── components/
│   │   ├── section_header.dart   # Reusable Lucide-icon header block
│   │   ├── stat_card.dart        # Grid block for Insights stats
│   │   ├── sparkline.dart        # CustomPainter line chart
│   │   ├── toggle_row.dart       # Form switch control
│   │   └── slider_row.dart       # Form slider control
│   ├── screens/
│   │   ├── onboarding_screen.dart # Swipeable onboarding welcome deck (3 cards)
│   │   ├── webview_screen.dart    # InAppWebView shell + bridge handler
│   │   ├── caught_up_overlay.dart # Dismissible overlays when limit is hit
│   │   ├── insights_screen.dart   # Dashboard compile screen
│   │   └── settings_screen.dart   # Configuration panel
│   └── injection/
│       └── build_injection_script.dart # Generates dynamic JS injection string
├── android/                      # Native Android project configuration
├── ios/                          # Native iOS project configuration
├── pubspec.yaml                  # Project dependencies list
└── PROJECT.md                    # This document
```

---

## 7. Detailed Specs (Build-Ready)

### 7.1 WebView Configuration — `lib/screens/webview_screen.dart`

Hosts `InAppWebView` with custom configuration parameters:
- **UserAgent:** Forced Mobile UserAgent to load mobile-web layout instead of desktop.
- **JavaScriptEnabled & DomStorageEnabled:** Enabled to persist logged-in sessions.
- **Initial User Script:** Early CSS hides are injected into the HTML document *before* page scripts run, preventing FOUC (Flash of Unstyled Content).
- **JavaScript Handlers:** Uses `controller.addJavaScriptHandler(handlerName: 'bridge')` to receive counts and events.

### 7.2 Cookie Backup Utility — `lib/storage/cookie_manager_util.dart`

To protect sessions against aggressive OS battery optimizations on some devices (Samsung, Xiaomi) that wipe WebView cookies, Lumora implements an automatic backup layer:

```dart
class CookieManagerUtil {
  static final CookieManager _cookieManager = CookieManager.instance();

  static Future<void> backupCookies(String urlString) async {
    final url = WebUri(urlString);
    final cookies = await _cookieManager.getCookies(url: url);
    final List<Map<String, dynamic>> cookieList = cookies.map((c) => {
      'name': c.name,
      'value': c.value,
      'domain': c.domain,
      'path': c.path,
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies_${url.host}', jsonEncode(cookieList));
  }

  static Future<void> restoreCookies(String urlString) async {
    final url = WebUri(urlString);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cookies_${url.host}');
    if (raw == null) return;

    final List<dynamic> cookieList = jsonDecode(raw);
    for (final c in cookieList) {
      await _cookieManager.setCookie(
        url: url,
        name: c['name'],
        value: c['value'],
        domain: c['domain'],
        path: c['path'] ?? '/',
      );
    }
  }
}
```

### 7.3 JS Injection Builder — `lib/injection/build_injection_script.dart`

Generates custom JS executed inside WebView containing:
- Static CSS hide sheets.
- Text text-content checks matching local languages (e.g., hiding "Sponsored" or "Suggested for you").
- Video autoplay restrictions.
- Capped observer listening to SPA updates to report current post count.

---

## 8. Acceptance Criteria (v1 "Done")

- [x] App loads `instagram.com` inside the WebView; login session persists correctly across restarts.
- [x] Persistent cookie backup/restore layer saves session parameters to `SharedPreferences`.
- [x] Content toggles successfully target CSS/DOM classes on Instagram mobile-web.
- [x] Video autoplay is disabled.
- [x] WebView logs post count updates; blocks viewport and presents `CaughtUpOverlay` when cap is reached.
- [x] Insights screen renders statistics using a custom sparkline canvas.
- [x] Local-only data operations: no telemetry endpoints configured.
- [x] Android `minSdkVersion` set to `26` for WebView stability.
- [x] Static analyzer clean (`flutter analyze` returns 0 issues).
- [x] Technical documentation updated for Flutter target stack.