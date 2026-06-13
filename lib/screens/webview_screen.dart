import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../theme/colors.dart';
import '../store/settings_provider.dart';
import '../store/session_provider.dart';
import '../store/config_provider.dart';
import '../components/branded_loading_screen.dart';
import '../storage/cookie_manager_util.dart';
import '../injection/build_injection_script.dart';
import 'caught_up_overlay.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String? _lastInjectionSignature;

  // Custom UserAgent to force Instagram mobile web version
  static const String mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (!kIsWeb) {
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );
      if (settingsProvider.cookieBackupEnabled) {
        CookieManagerUtil.restoreCookies('https://www.instagram.com');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    if (!kIsWeb &&
        settingsProvider.cookieBackupEnabled &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive)) {
      // Backup cookies when the app goes into background
      CookieManagerUtil.backupCookies('https://www.instagram.com');
    }
  }

  void _injectScripts(BuildContext context) {
    if (_webViewController == null) return;

    final configProvider = Provider.of<ConfigProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );

    // Build the UserSettings structure as a Map
    final Map<String, dynamic> settingsMap = {
      'sessionLimit': sessionProvider.startedAt == null
          ? settingsProvider.sessionLimit
          : sessionProvider.activeLimit,
      'currentPostsViewed': sessionProvider.postsViewed,
      'confirmBeforeExtending': settingsProvider.confirmBeforeExtending,
      'hideReels': settingsProvider.hideReels,
      'hideExplore': settingsProvider.hideExplore,
      'hideSuggested': settingsProvider.hideSuggested,
      'hideSponsored': settingsProvider.hideSponsored,
      'hideLiveShopping': settingsProvider.hideLiveShopping,
      'disableAutoplay': settingsProvider.disableAutoplay,
    };

    final String js = buildInjectionScript(configProvider.config, settingsMap);
    _webViewController!.evaluateJavascript(source: js);
    _lastInjectionSignature = jsonEncode({
      'settings': {
        'sessionLimit': settingsMap['sessionLimit'],
        'confirmBeforeExtending': settingsMap['confirmBeforeExtending'],
        'hideReels': settingsMap['hideReels'],
        'hideExplore': settingsMap['hideExplore'],
        'hideSuggested': settingsMap['hideSuggested'],
        'hideSponsored': settingsMap['hideSponsored'],
        'hideLiveShopping': settingsMap['hideLiveShopping'],
        'disableAutoplay': settingsMap['disableAutoplay'],
      },
      'configVersion': configProvider.configVersion,
    });
  }

  void _handleCloseSession(SessionProvider sessionProvider) {
    sessionProvider.endSession();
    // Navigate user away or show Insights
    Navigator.of(context).pushNamed('/insights');
  }

  void _handleExtendSession(SessionProvider sessionProvider) {
    sessionProvider.extendSession(5);
    // Tell the injected Javascript that the limit has increased
    _webViewController?.evaluateJavascript(
      source:
          'if (window.__lumoraSettings) { window.__lumoraSettings.sessionLimit = ${sessionProvider.activeLimit}; if (window.__lumoraRefresh) window.__lumoraRefresh(); }',
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final settingsProvider = Provider.of<SettingsProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    final configProvider = Provider.of<ConfigProvider>(context);

    final injectionSignature = jsonEncode({
      'settings': {
        'sessionLimit': sessionProvider.startedAt == null
            ? settingsProvider.sessionLimit
            : sessionProvider.activeLimit,
        'confirmBeforeExtending': settingsProvider.confirmBeforeExtending,
        'hideReels': settingsProvider.hideReels,
        'hideExplore': settingsProvider.hideExplore,
        'hideSuggested': settingsProvider.hideSuggested,
        'hideSponsored': settingsProvider.hideSponsored,
        'hideLiveShopping': settingsProvider.hideLiveShopping,
        'disableAutoplay': settingsProvider.disableAutoplay,
      },
      'configVersion': configProvider.configVersion,
    });

    if (!_isLoading &&
        _webViewController != null &&
        _lastInjectionSignature != injectionSignature) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _injectScripts(context);
        }
      });
    }

    // Calculate time saved: baseline usage time minus actual elapsed session time
    int estimatedTimeSaved = 0;
    if (sessionProvider.startedAt != null) {
      final actualMinutes = DateTime.now()
          .difference(sessionProvider.startedAt!)
          .inMinutes;
      estimatedTimeSaved = (settingsProvider.baselineMinutes - actualMinutes)
          .clamp(0, settingsProvider.baselineMinutes);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Header title bar
              Container(
                color: AppColors.surface,
                padding: EdgeInsets.only(
                  top: statusBarHeight + 8,
                  bottom: 12,
                  left: 16,
                  right: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Choose app',
                          icon: const Icon(
                            LucideIcons.arrowLeft,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/home');
                          },
                        ),
                        const Text(
                          'Lumora',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          child: const Text(
                            'Instagram',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            LucideIcons.barChart2,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/insights'),
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.settings,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Address hint
              Container(
                width: double.infinity,
                color: AppColors.surface.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                child: const Text(
                  'instagram.com — official site loaded securely',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // WebView container
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri('https://www.instagram.com'),
                  ),
                  initialSettings: InAppWebViewSettings(
                    userAgent: mobileUserAgent,
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    databaseEnabled: true,
                    thirdPartyCookiesEnabled: true,
                    sharedCookiesEnabled: true,
                    supportZoom: false,
                    useShouldOverrideUrlLoading: true,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;

                    if (!kIsWeb) {
                      // Register the bridge Javascript handler
                      controller.addJavaScriptHandler(
                        handlerName: 'bridge',
                        callback: (args) {
                          if (args.isEmpty) return;

                          try {
                            final Map<String, dynamic> msg = args[0] is String
                                ? jsonDecode(args[0])
                                : Map<String, dynamic>.from(args[0]);

                            final String type = msg['type'] ?? '';
                            if (type == 'postCountUpdate') {
                              final int count = msg['count'] ?? 0;
                              // Ensure session is started in provider if not already
                              if (sessionProvider.startedAt == null) {
                                sessionProvider.startSession(
                                  'instagram',
                                  settingsProvider.sessionLimit,
                                );
                              }
                              sessionProvider.updatePostCount(count);
                            } else if (type == 'caughtUp') {
                              final int count = msg['count'] ?? 0;
                              sessionProvider.updatePostCount(count);
                            }
                          } catch (_) {
                            // Fail-soft
                          }
                        },
                      );
                    }
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      _isLoading = true;
                    });

                    if (!kIsWeb) {
                      // Restore session cookies on new load start
                      if (settingsProvider.cookieBackupEnabled) {
                        CookieManagerUtil.restoreCookies(
                          'https://www.instagram.com',
                        );
                      }
                    }
                  },
                  onLoadStop: (controller, url) async {
                    setState(() {
                      _isLoading = false;
                    });

                    // Start session logging if we are on the main feed (not login screen)
                    final urlString = url?.toString() ?? '';
                    if (!urlString.contains('accounts/login')) {
                      if (sessionProvider.startedAt == null) {
                        sessionProvider.startSession(
                          'instagram',
                          settingsProvider.sessionLimit,
                        );
                      }
                    }

                    // Inject Hiding and DOM modification scripts
                    _injectScripts(context);
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                        final url = navigationAction.request.url;
                        if (url != null) {
                          final urlString = url.toString();
                          final isExternal =
                              !urlString.contains('instagram.com') &&
                              !urlString.contains(
                                'facebook.com',
                              ); // IG redirects sometimes

                          if (settingsProvider.openLinksExternally &&
                              isExternal) {
                            // Open external link in system browser
                            await InAppBrowser.openWithSystemBrowser(url: url);
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                ),
              ),

              // Bottom Limit Counter
              if (!_isLoading)
                Container(
                  color: AppColors.surface,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: bottomPadding + 12,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Posts viewed',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${sessionProvider.postsViewed}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                ' / ${sessionProvider.activeLimit}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          height: 4,
                          child: LinearProgressIndicator(
                            value:
                                (sessionProvider.postsViewed /
                                        sessionProvider.activeLimit)
                                    .clamp(0.0, 1.0),
                            backgroundColor: AppColors.surfaceAlt,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Loading Screen
          if (_isLoading)
            const BrandedLoadingScreen(
              message: 'Opening Instagram through Lumora',
              showWordmark: false,
            ),

          // Caught Up Overlay Modal
          CaughtUpOverlay(
            visible: sessionProvider.isCaughtUp,
            postCount: sessionProvider.postsViewed,
            estimatedTimeSaved: estimatedTimeSaved,
            onClose: () => _handleCloseSession(sessionProvider),
            onExtend: () => _handleExtendSession(sessionProvider),
            onAdjustLimit: () {
              sessionProvider.endSession();
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
    );
  }
}
