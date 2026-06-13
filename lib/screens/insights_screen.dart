import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/colors.dart';
import '../store/session_provider.dart';
import '../store/settings_provider.dart';
import '../components/stat_card.dart';
import '../storage/session_storage.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final List<SessionRecord> history = sessionProvider.history;
    final today = DateTime.now();
    final weekStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));
    final List<SessionRecord> weeklyHistory = history
        .where((record) => !record.endedAt.isBefore(weekStart))
        .toList();

    // 1. Calculate Stats
    final int totalSessions = weeklyHistory.length;
    final int totalPosts = weeklyHistory.fold(
      0,
      (sum, r) => sum + r.postsViewed,
    );
    final double avgPostsPerSession = totalSessions == 0
        ? 0
        : totalPosts / totalSessions;

    // Calculate time saved: baselineMinutes - actualSessionMinutes for each session
    int totalTimeSavedMinutes = 0;
    for (final record in weeklyHistory) {
      final actualMinutes = record.endedAt
          .difference(record.startedAt)
          .inMinutes;
      final saved = settingsProvider.baselineMinutes - actualMinutes;
      if (saved > 0) {
        totalTimeSavedMinutes += saved;
      }
    }

    // Calculate Streak (consecutive days where user stayed within limit)
    final int streakDays = _calculateStreak(history);

    // Get weekly activity data (last 7 days)
    final List<int> weeklyActivity = _getWeeklyActivity(history);
    final List<String> dayLabels = _getWeeklyDayLabels();

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
                  'Insights',
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
                // Hero Stat: Time Saved
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TIME SAVED THIS WEEK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalTimeSavedMinutes',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const Text(
                        'minutes',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'estimated · based on a ${settingsProvider.baselineMinutes}-min baseline',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stat Cards Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Sessions',
                          value: '$totalSessions',
                          sublabel: 'this week',
                          icon: const Icon(
                            LucideIcons.activity,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Posts',
                          value: '$totalPosts',
                          sublabel: '~${avgPostsPerSession.round()}/session',
                          icon: const Icon(
                            LucideIcons.eye,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Streak Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CURRENT STREAK',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$streakDays',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'days',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'stayed within your limit',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        // Visual Streak Indicators
                        Row(
                          children: List.generate(7, (index) {
                            final bool isActive = index < streakDays;
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2.5,
                              ),
                              width: 10,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.warning.withOpacity(0.8)
                                    : AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Weekly Activity Bar Chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'POSTS VIEWED — LAST 7 DAYS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Bar Chart Layout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            final int val = weeklyActivity[index];
                            final int maxVal = weeklyActivity.reduce(
                              (a, b) => a > b ? a : b,
                            );
                            final double maxValDouble = maxVal == 0
                                ? 1.0
                                : maxVal.toDouble();
                            final double heightPercent = val / maxValDouble;
                            final double height = (heightPercent * 80).clamp(
                              8.0,
                              80.0,
                            );
                            final bool isToday = index == 6;

                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '$val',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: height,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? AppColors.accent
                                          : AppColors.accent.withOpacity(0.3),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    dayLabels[index],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isToday
                                          ? AppColors.accent
                                          : AppColors.textSecondary.withOpacity(
                                              0.5,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Recent Sessions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RECENT SESSIONS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (history.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Text(
                                'No sessions logged yet.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: history.length.clamp(0, 5),
                            separatorBuilder: (context, index) => const Divider(
                              height: 20,
                              color: AppColors.divider,
                            ),
                            itemBuilder: (context, index) {
                              // Display in reverse chronological order
                              final session =
                                  history[history.length - 1 - index];
                              final elapsedMin = session.endedAt
                                  .difference(session.startedAt)
                                  .inMinutes;
                              final timeAgoString = _getTimeAgo(
                                session.endedAt,
                              );

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${session.postsViewed} posts viewed (${elapsedMin}m)',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        timeAgoString,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (session.extended) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                          ),
                                          child: const Text(
                                            'extended',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.warning,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Icon(
                                        session.postsViewed <= session.limit
                                            ? LucideIcons.check
                                            : LucideIcons.arrowRight,
                                        size: 16,
                                        color:
                                            session.postsViewed <= session.limit
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Pro Upsell Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.05),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              LucideIcons.sparkles,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Lumora Pro',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Unlock weekly trends, custom themes, focus schedules, and session notes. One-time purchase, no subscription.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Premium features coming in v1.1',
                                ),
                                backgroundColor: AppColors.surfaceAlt,
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                              border: Border.all(
                                color: AppColors.accent.withOpacity(0.2),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Learn More',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate streak days
  int _calculateStreak(List<SessionRecord> history) {
    if (history.isEmpty) return 0;

    // Sort by date descending
    final sorted = List<SessionRecord>.from(history)
      ..sort((a, b) => b.endedAt.compareTo(a.endedAt));

    int streak = 0;
    DateTime? lastDate;

    for (final record in sorted) {
      final date = DateTime(
        record.endedAt.year,
        record.endedAt.month,
        record.endedAt.day,
      );
      if (record.postsViewed <= record.limit) {
        if (lastDate == null) {
          streak++;
          lastDate = date;
        } else {
          final diff = lastDate.difference(date).inDays;
          if (diff == 1) {
            streak++;
            lastDate = date;
          } else if (diff > 1) {
            break; // Streak broken
          }
        }
      } else {
        break; // Limit exceeded, streak broken
      }
    }

    return streak;
  }

  // Aggregates post count for the last 7 days
  List<int> _getWeeklyActivity(List<SessionRecord> history) {
    final List<int> activity = List.filled(7, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final record in history) {
      final recordDate = DateTime(
        record.endedAt.year,
        record.endedAt.month,
        record.endedAt.day,
      );
      final daysAgo = today.difference(recordDate).inDays;
      if (daysAgo >= 0 && daysAgo < 7) {
        // Index 6 is today, index 0 is 6 days ago
        activity[6 - daysAgo] += record.postsViewed;
      }
    }
    return activity;
  }

  // Generates day-of-week labels for the last 7 days
  List<String> _getWeeklyDayLabels() {
    final List<String> weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    final List<String> labels = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      labels.add(weekdays[date.weekday - 1]);
    }
    return labels;
  }

  // Returns simple time-ago label
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
