import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/colors.dart';
import '../store/settings_provider.dart';

class OnboardingCardData {
  final String title;
  final String subtitle;
  final String body;
  final Widget illustration;

  OnboardingCardData({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.illustration,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _activeIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding(BuildContext context) {
    Provider.of<SettingsProvider>(context, listen: false).completeOnboarding();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _nextPage() {
    if (_activeIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final List<OnboardingCardData> cards = [
      OnboardingCardData(
        title: 'Your feeds,',
        subtitle: 'without the undertow.',
        body:
            'Use the apps you love, minus the parts that use you. Lumora wraps your social feeds and removes the doomscroll mechanics — Reels, Explore, ads, infinite scroll — while keeping everything you actually came for.',
        illustration: _buildFeedsIllustration(),
      ),
      OnboardingCardData(
        title: 'Everything stays',
        subtitle: 'on your phone.',
        body:
            'No servers. No tracking. No accounts. We literally can\'t see your data. You log in through the real site — Lumora just changes what you see, never what gets sent.',
        illustration: _buildShieldIllustration(),
      ),
      OnboardingCardData(
        title: 'Scroll less.',
        subtitle: 'See more. Leave lighter.',
        body:
            'Set a session limit. Toggle what you hide. See how much time you\'ve saved. And when you\'re done, close the app — it should feel like a natural exhale, not a fight.',
        illustration: _buildTimerIllustration(),
      ),
    ];

    final bool isLastCard = _activeIndex == cards.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Skip Button
          if (!isLastCard)
            Positioned(
              top: statusBarHeight + 16,
              right: 24,
              child: GestureDetector(
                onTap: () => _completeOnboarding(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

          // Slide Content
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _activeIndex = index;
                    });
                  },
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          card.illustration,
                          const SizedBox(height: 40),
                          Text(
                            card.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            card.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            card.body,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Control Area
              Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: bottomPadding + 20.0,
                ),
                child: Column(
                  children: [
                    // Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(cards.length, (index) {
                        final bool isActive = _activeIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 8,
                          width: isActive ? 20 : 8,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(
                              isActive ? 1.0 : 0.25,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Navigation Button
                    GestureDetector(
                      onTap: isLastCard
                          ? () => _completeOnboarding(context)
                          : _nextPage,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLastCard ? 'Get Started' : 'Continue',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLastCard
                                  ? LucideIcons.check
                                  : LucideIcons.arrowRight,
                              size: 16,
                              color: AppColors.background,
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
        ],
      ),
    );
  }

  // Card 1 Illustration (Mock Phone with Feed)
  Widget _buildFeedsIllustration() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Glow
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
          // Phone Wrapper
          Container(
            width: 250,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.1),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 60,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.sparkles,
                        size: 10,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Feed Item 1
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 48,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Feed Item 2
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 64,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
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

  // Card 2 Illustration (Shield Logo)
  Widget _buildShieldIllustration() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Glow
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
          // Nested Circles
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.05),
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.warning.withOpacity(0.15)),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.shield,
                  size: 36,
                  color: AppColors.warning,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 3 Illustration (Timer/Limit Gauge)
  Widget _buildTimerIllustration() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Glow
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
          // circular outline
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.05),
              ),
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom Paint for Arc
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(painter: _GaugePainter()),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.timer,
                    size: 28,
                    color: AppColors.accent,
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

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withOpacity(0.1)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);

    final activePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw active arc (representing ~70% limit)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -1.5, // Start angle (roughly top)
      4.2, // Sweep angle
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
