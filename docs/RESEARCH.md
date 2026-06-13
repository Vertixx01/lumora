# Lumora — Pre-Build Research & Strategic Analysis

> Research completed before scaffolding. Covers monetization, Android target, selector strategy, competitive landscape, and revised technical recommendations for the Flutter-based implementation.

---

## 1. Monetization Strategy

### The Constraint

Lumora is AGPL-3.0, fully on-device, zero-telemetry, open-source. This rules out ads, data selling, and traditional SaaS. But it doesn't rule out *revenue*. The key insight from studying successful privacy apps:

> **Users don't pay to remove limits — they pay for *premium calm*.**

### Recommended Model: Hybrid Freemium + Community Funding

A three-layer approach, ordered by priority:

#### Layer 1: "Lumora Pro" — One-Time Purchase ($4.99–$6.99)

The free version is fully functional (all hiding, session cap, basic insights). Pro unlocks *premium self-insight and customization*:

| Pro Feature | Why Users Pay For It | Effort |
|---|---|---|
| **Advanced Insights** — weekly/monthly trend charts, "best day" streaks, per-network time breakdowns | Users of screen-time apps consistently cite "deep insights" as the #1 paid feature | Medium |
| **Custom Themes** — additional calm palettes (forest, ocean, dawn), AMOLED dark, custom accent colors | Personalization drives attachment. Low dev cost, high perceived value | Low |
| **Focus Schedules** — auto-apply different session limits by day/time (weekday strict, weekend relaxed) | #2 most-requested premium feature in digital wellbeing apps | Medium |
| **Session Notes** — add a one-line reflection after each session ("felt good about stopping early") | Journaling-adjacent; differentiator vs. competitors | Low |
| **Stats Export** — PDF/JSON export of all insights data | Power users and parents want this | Low |
| **Multi-Network Insights** (v2) — unified cross-platform dashboard | Natural upsell when YouTube/X adapters ship | Later |

> [!IMPORTANT]
> **One-time purchase, not subscription.** The target audience is subscription-fatigued. A single $4.99 payment aligns with Lumora's "honest, no dark patterns" brand. This is a deliberate competitive advantage — competitors like one sec and Opal charge $40–$70/year.

#### Layer 2: Community Funding (Ongoing)

| Channel | Purpose | Setup Effort |
|---|---|---|
| **GitHub Sponsors** | Recurring monthly sponsorships from developers & power users | Low |
| **Ko-fi** | One-time "buy me a coffee" tips from casual supporters | Low |
| **Open Collective** | Transparent fund for infrastructure costs (hosting config CDN, CI, etc.) | Low |

**Tier structure for GitHub Sponsors:**

| Tier | Price | Perks |
|---|---|---|
| ☕ Supporter | $3/mo | Name in SUPPORTERS.md, Discord "Supporter" role |
| 🌟 Champion | $10/mo | Above + voting on feature roadmap, early access builds |
| 💎 Lifetime | $50 one-time | Permanent "Founding Supporter" badge in README + Discord |

#### Layer 3: Ethical Partnerships (Future, v2+)

Once Lumora has meaningful user numbers (10k+ installs):

- **Digital wellbeing organizations** (e.g., Center for Humane Technology) — co-marketing partnerships, not paid sponsorships
- **Privacy-focused services** (e.g., Proton, Mullvad) — tasteful "recommended by" section in About, with full disclosure. User-optional, never pushed.
- **No affiliate tracking.** Links only, never cookies or tracking parameters.

### Revenue Projection (Conservative)

| Source | Year 1 Estimate | Notes |
|---|---|---|
| Pro purchases (5% conversion, 5k users) | ~$1,250 | Conservative. FocusGram-type apps see 3–8% conversion |
| GitHub Sponsors | ~$600 | Based on similar FOSS project patterns |
| Ko-fi / donations | ~$300 | Sporadic but compounds with community growth |
| **Total** | **~$2,150** | Covers CI/CD costs, domain, and contributor rewards |

> [!NOTE]
> Year 1 revenue won't fund a salary — and it shouldn't need to. Lumora is an open-source passion project. The goal is **sustainability** (covering infrastructure costs) not profitability. If it takes off (50k+ users), Pro revenue scales linearly without any changes to the model.

### What NOT To Do

- ❌ **No subscription paywalls** — contradicts the brand
- ❌ **No "nag screens"** to upgrade — one tasteful mention in Settings > About, and a "Get Pro" badge in Insights (non-intrusive)
- ❌ **No ads of any kind** — ever
- ❌ **No premium-gating core hiding features** — the privacy/distraction-free promise must be fully free
- ❌ **No "Pro trial" that expires** — if someone has the free version, it works forever

---

## 2. Android API Level Recommendation

### The Analysis

| API Level | Android Version | Key WebView Capability | Market Share (approx mid-2026) |
|---|---|---|---|
| 23 (6.0) | Marshmallow | Auto-updating WebView via Play Store begins | ~2% |
| 24 (7.0) | Nougat | Chrome WebView becomes default, multi-window | ~3% |
| 26 (8.0) | Oreo | Autofill framework, adaptive icons, `WebView.setSafeBrowsingEnabled()` | ~5% |
| 28 (9.0) | Pie | HTTPS by default, display cutout support | ~7% |
| 29 (10) | Q | Scoped storage, dark theme support | ~10% |
| 31 (12) | S | Material You, splash screen API | ~18% |
| 33 (13) | Tiramisu | Per-app language, photo picker | ~20% |
| 34 (14) | Upside Down Cake | Predictive back, partial screen sharing | ~18% |
| 35 (15) | Vanilla Ice Cream | Enforced edge-to-edge layout, optimized rendering | ~12% |

### Recommendation: **API 26 (Android 8.0 Oreo)**

**Rationale:**

1. **WebView reliability** — API 26+ guarantees Chrome-based WebView with reliable cookie persistence APIs and modern JS engine. Below this, WebView behavior is wildly inconsistent across OEMs.
2. **Library compatibility** — The native WebView library `flutter_inappwebview` requires a solid API foundation for features like custom user scripts, intercepting AJAX requests, and managing web cookies.
3. **Market coverage** — API 26+ covers **~93%** of active Android devices in mid-2026. The remaining 7% are mostly devices that won't run Instagram's own mobile web properly anyway.
4. **Google Play requirement** — By August 2026, new apps must target API 35/36. The `targetSdkVersion` must be 35/36, but `minSdkVersion` 26 is the smart floor.
5. **F-Droid compatibility** — API 26 is perfectly acceptable for F-Droid. No conflicts.

```kotlin
// android/app/build.gradle.kts
android {
    defaultConfig {
        minSdk = 26          // Android 8.0 — reliable WebView + cookie persistence
        targetSdk = 35       // Android 15 / 16 — Google Play compliance
    }
}
```

> [!TIP]
> If Lumora gains traction in emerging markets (India, Southeast Asia) where older devices persist, API 24 could be reconsidered. But for v1, API 26 avoids a whole class of WebView bugs and keeps the test matrix manageable.

---

## 3. Selector Sourcing Strategy

### The Problem

Instagram's mobile web DOM uses Meta's **StyleX** CSS-in-JS framework, which generates obfuscated class names like `x1lliihq`, `x1n2onr6`. These change on every build deployment (roughly weekly). CSS class selectors **will break constantly**.

### The Solution: Multi-Layer Selector Strategy

#### Layer 1: ARIA-First Selectors (Most Stable)

Instagram must maintain ARIA attributes for WCAG accessibility compliance. These change far less frequently than class names:

```json
{
  "selectors": {
    "feedContainer": ["[role='feed']", "[role='main'] > div"],
    "postItem": ["[role='article']", "article"],
    "reelsTab": ["a[href='/reels/']", "[aria-label*='Reels']"],
    "exploreTab": ["a[href='/explore/']", "[aria-label*='Explore']"],
    "videoNodes": ["video", "[role='presentation'] video"]
  }
}
```

#### Layer 2: Structural/Semantic Selectors (Moderately Stable)

Target DOM structure and HTML tags rather than classes:

```javascript
// Instead of: document.querySelector('.x1lliihq')
// Use:        document.querySelector('nav > div > div > a[href="/explore/"]')

// Sponsored posts — text-based detection (from labelMap)
const sponsoredLabels = ["Sponsored", "Paid partnership", "Gesponsert", "Sponsorisé"];
posts.forEach(post => {
  const text = post.textContent;
  if (sponsoredLabels.some(label => text.includes(label))) {
    post.style.display = 'none';
  }
});
```

#### Layer 3: Obfuscated Class Fallbacks (Least Stable, Most Precise)

Used only when ARIA/structural selectors can't isolate a target. These live in the remote config and are the ones that get community-updated:

```json
{
  "selectors": {
    "suggestedPosts": [
      "[role='article']:has(span:contains('Suggested for you'))",
      "div.x1lliihq > div.x9f619"
    ]
  }
}
```

### Automated Health Monitoring

Build a simple CI job that checks selector health weekly:

```yaml
# .github/workflows/selector-health.yml
name: Selector Health Check
on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 6am UTC
  workflow_dispatch:

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npx playwright install chromium
      - run: node scripts/check-selectors.js
      - name: Open issue on failure
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '🔴 Selector breakage detected',
              body: 'The weekly selector health check failed. See workflow logs.',
              labels: ['selectors', 'urgent']
            });
```

The `check-selectors.js` script would:
1. Launch a headless browser to `instagram.com` (logged out — we only need DOM structure)
2. Test each selector category against the live DOM
3. Report which selectors matched zero elements
4. Auto-open a GitHub issue when breakage is detected

### Community Maintenance Workflow

```
User reports breakage → GitHub Issue (template provided)
    ↓
Contributor inspects mobile web DOM (documented in SELECTOR_MAINTENANCE.md)
    ↓
PR to update networks/instagram.selectors.json
    ↓
Merge → GitHub Raw / CDN serves updated config
    ↓
Users get fix on next app launch (no app store update needed)
```

---

## 4. Competitive Landscape

### Direct Competitors (Instagram Wrappers)

| App | Platform | Model | Strengths | Weaknesses vs. Lumora |
|---|---|---|---|---|
| **FocusGram** | Android (FOSS) | Free | Blocks Reels/Explore/Shop, timed sessions | No insights dashboard, basic UI, no multi-network vision |
| **FeurStagram** | Android (FOSS) | Free | Blocks home feed entirely, hides Reels/Explore | Too aggressive — blocks feed entirely, no session cap |
| **JustAgram** | Android | Free | Toggles for Reels/Stories/Explore | Minimal features, no analytics, unclear maintenance |

### Indirect Competitors (Digital Wellbeing Apps)

| App | Model | Price | Relevance |
|---|---|---|---|
| **one sec** | Subscription | $40/yr | Adds friction before opening apps, not a wrapper |
| **Opal** | Subscription | $50–$100/yr | App blocker, not content-level control |
| **Freedom** | Subscription | $40/yr | Cross-platform blocker, no content filtering |

### Lumora's Competitive Advantages

1. **Content-level surgery** — competitors block entire apps; Lumora removes *specific features* while keeping the useful parts.
2. **Insights as retention** — none of the FOSS wrappers have an analytics dashboard. This is Lumora's sticky feature.
3. **Multi-network design** — Designed from day one with adapter-based architecture.
4. **One-time Pro purchase** — every subscription competitor charges $40–$100/yr. Lumora Pro at $4.99 one-time is a category-killer price point.
5. **Brand voice** — "calm, honest, never guilt-trippy" is genuinely unique in a space full of productivity-shaming apps.

---

## 5. F-Droid Compliance Path

### The Analysis

F-Droid requires 100% FOSS + reproducible builds from source. Flutter applications are highly suited for F-Droid because Flutter compiles to native ARM code without requiring proprietary build pipelines (like React Native EAS).

### The Solution

| Requirement | Action |
|---|---|
| **Build from source** | Run `flutter build apk --release` to generate the native Android release APK directly. |
| **Remove proprietary SDKs** | Verify that no Firebase, Google Play Services, or Facebook SDKs are included in `pubspec.yaml` or Android native folders. |
| **License** | AGPL-3.0 ✅ — already F-Droid compatible. |
| **Metadata** | Add Fastlane metadata description and screenshots to publish the app cleanly. |

---

## 6. Technical Recommendations (Flutter Stack)

### 6.1 Cookie Persistence & Sync

The standard WebView cookie management can be inconsistent across Android OS configurations. Lumora implements a **persistent backup layer** using `InAppCookieManager` from `flutter_inappwebview` combined with `shared_preferences` storage:

```dart
// lib/storage/cookie_manager_util.dart
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

### 6.2 Login Wall Detection

The WebView injection layer listens for and automatically dismisses "Not Now" app promo login screens on Instagram:

```javascript
function dismissLoginWalls() {
  const dismissSelectors = [
    '[role="button"][aria-label="Not Now"]',
    'button[aria-label="Not Now"]',
    '[role="dialog"] [role="button"]:last-child',
  ];
  dismissSelectors.forEach(sel => {
    try {
      document.querySelectorAll(sel).forEach(btn => btn.click());
    } catch (_) {}
  });
}
```

### 6.3 State Management

We use **Provider** + **ChangeNotifier** for clean global state management. This facilitates communication between the native application (settings, session logs, dashboard statistics) and the WebView bridge:

- `SettingsProvider`: Stores and persists UI hiding configurations (hide Reels, Explore, Sponsored, etc.) and post limits.
- `SessionProvider`: Logs actual session parameters, computes time saved, and handles caught-up overlay state.
- `ConfigProvider`: Handles selector updates in the background.

---

## 7. Package Summary

The following Flutter packages form the core of the implementation:

| Package | Purpose | Category |
|---|---|---|
| `flutter_inappwebview` | Premium WebView controller with early script injection support | Core WebView |
| `provider` | State management provider tree | State Management |
| `shared_preferences` | Key-value store for configurations and local settings cache | Storage |
| `path_provider` | Local filesystem directory path lookup for file-based session logs | Storage |
| `lucide_icons` | Cozy, pixel-perfect vector icons for headers and menus | UI / Icons |
| `flutter_svg` | Vector illustration renderer for onboarding and overlay screens | UI / Assets |
