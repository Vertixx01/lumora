import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../app_info.dart';
import '../theme/colors.dart';
import '../store/settings_provider.dart';
import '../components/section_header.dart';
import '../components/toggle_row.dart';
import '../storage/cookie_manager_util.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.only(
              top: statusBarHeight + 8,
              bottom: 12,
              left: 8,
              right: 16,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    LucideIcons.chevronLeft,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: bottomPadding + 32.0, top: 8.0),
              children: [
                // Session Limit Section
                const SectionHeader(title: 'Session'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Session Limit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.surfaceAlt,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '${settingsProvider.sessionLimit} posts',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Quick Set Buttons
                              Row(
                                children: [10, 20, 30, 50].map((val) {
                                  final bool isSelected =
                                      settingsProvider.sessionLimit == val;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => settingsProvider
                                          .updateSetting('sessionLimit', val),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.accent
                                              : AppColors.surfaceAlt,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$val',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppColors.background
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ToggleRow(
                          label: 'Confirm before extending',
                          description: 'Ask before adding more posts',
                          value: settingsProvider.confirmBeforeExtending,
                          onValueChange: (v) => settingsProvider.updateSetting(
                            'confirmBeforeExtending',
                            v,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // App Controls Section
                const SectionHeader(
                  title: 'App Controls',
                  subtitle: 'Choose what Lumora shows or hides per network',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/icons/instagram.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.accent,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Instagram',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Home feed, DMs, profiles, posting, and search stay available.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ToggleRow(
                          label: 'Hide Reels',
                          description: 'Remove Reels tab and entry points',
                          value: settingsProvider.hideReels,
                          onValueChange: (v) =>
                              settingsProvider.updateSetting('hideReels', v),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ToggleRow(
                          label: 'Hide Explore',
                          description: 'Remove Explore / Discover surfaces',
                          value: settingsProvider.hideExplore,
                          onValueChange: (v) =>
                              settingsProvider.updateSetting('hideExplore', v),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ToggleRow(
                          label: 'Hide Suggested',
                          description: 'Remove "Suggested for you" posts',
                          value: settingsProvider.hideSuggested,
                          onValueChange: (v) => settingsProvider.updateSetting(
                            'hideSuggested',
                            v,
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ToggleRow(
                          label: 'Hide Ads',
                          description:
                              'Remove posts marked Ad, Sponsored, or Paid partnership',
                          value: settingsProvider.hideSponsored,
                          onValueChange: (v) => settingsProvider.updateSetting(
                            'hideSponsored',
                            v,
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ToggleRow(
                          label: 'Hide Live & Shopping',
                          description:
                              'Remove Live badges and Shopping modules',
                          value: settingsProvider.hideLiveShopping,
                          onValueChange: (v) => settingsProvider.updateSetting(
                            'hideLiveShopping',
                            v,
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ToggleRow(
                          label: 'Disable Autoplay',
                          description: 'Pause all videos automatically',
                          value: settingsProvider.disableAutoplay,
                          onValueChange: (v) => settingsProvider.updateSetting(
                            'disableAutoplay',
                            v,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Behavior Section
                const SectionHeader(title: 'Behavior'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      children: [
                        ToggleRow(
                          label: 'Open links externally',
                          description: 'External links open in system browser',
                          value: settingsProvider.openLinksExternally,
                          onValueChange: (v) => settingsProvider.updateSetting(
                            'openLinksExternally',
                            v,
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ToggleRow(
                          label: 'Haptics',
                          description: 'Subtle feedback on confirmations',
                          value: settingsProvider.hapticsEnabled,
                          onValueChange: (v) => settingsProvider.updateSetting(
                            'hapticsEnabled',
                            v,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Privacy Section
                const SectionHeader(title: 'Privacy'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No Telemetry',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'No analytics, accounts, or tracking endpoints.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text(
                                  'Always On',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        ToggleRow(
                          label: 'Cookie backup',
                          description:
                              'Locally save WebView cookies to protect your login session',
                          value: settingsProvider.cookieBackupEnabled,
                          onValueChange: (v) => settingsProvider.updateSetting(
                            'cookieBackupEnabled',
                            v,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // About Section
                const SectionHeader(title: 'About'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'App Version',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              _AppVersionText(),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: AppColors.divider),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Active Network',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Instagram',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: AppColors.divider),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'License',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'AGPL-3.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Clear WebView Cache Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            await WebStorageManager.instance().deleteAllData();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Website cache cleared successfully.',
                                ),
                                backgroundColor: AppColors.surfaceAlt,
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error clearing website cache.'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12),
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Clear Website Cache',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Clears cached data only. You won\'t be logged out.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await CookieManagerUtil.clearCookies(
                              'https://www.instagram.com',
                            );
                            await WebStorageManager.instance().deleteAllData();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Instagram cookies cleared. You will need to log in again.',
                                ),
                                backgroundColor: AppColors.surfaceAlt,
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error clearing cookies.'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12),
                            ),
                            border: Border.all(
                              color: AppColors.danger.withOpacity(0.28),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Log Out & Clear Cookies',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Removes Instagram cookies and local cookie backup.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppVersionText extends StatelessWidget {
  const _AppVersionText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      AppInfo.version,
      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
    );
  }
}
