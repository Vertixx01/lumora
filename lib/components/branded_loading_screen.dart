import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class BrandedLoadingScreen extends StatefulWidget {
  final String message;
  final bool showWordmark;

  const BrandedLoadingScreen({
    Key? key,
    this.message = 'Preparing your calmer feed',
    this.showWordmark = true,
  }) : super(key: key);

  @override
  State<BrandedLoadingScreen> createState() => _BrandedLoadingScreenState();
}

class _BrandedLoadingScreenState extends State<BrandedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final pulse =
                0.96 + (math.sin(_controller.value * math.pi * 2) + 1) * 0.02;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.18),
                          blurRadius: 34,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.24),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/lumora_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (widget.showWordmark) ...[
                  const SizedBox(height: 22),
                  const Text(
                    'Lumora',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                _LoadingBar(progress: _controller.value),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  final double progress;

  const _LoadingBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt.withOpacity(0.72),
                ),
              ),
            ),
            Align(
              alignment: Alignment(-1.4 + (progress * 2.8), 0),
              child: Container(
                width: 58,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
